module ocn_cap_methods

  use ESMF,                only: ESMF_clock, ESMF_time, ESMF_ClockGet, ESMF_TimeGet
  use MOM_ocean_model,     only: ocean_public_type, ocean_state_type
  use MOM_surface_forcing, only: ice_ocean_boundary_type
  use MOM_grid,            only: ocean_grid_type
  use MOM_domains,         only: pass_var
  use MOM_error_handler,   only: is_root_pe
  use mpp_domains_mod,     only: mpp_get_compute_domain
  use ocn_cpl_indices,     only: cpl_indices_type

  implicit none
  private

  public :: ocn_import
  public :: ocn_export

!=======================================================================
contains
!=======================================================================

!> Maps incomping ocean data to MOM6 data structures
subroutine ocn_import(x2o, ind, ocean_grid, ice_ocean_boundary, ocean_public, logunit, Eclock, c1, c2, c3, c4)

  real(kind=8)                  , intent(in)    :: x2o(:,:)           !< incoming data
  type(cpl_indices_type)        , intent(in)    :: ind                !< Structure with MCT attribute vects and indices
  type(ocean_grid_type)         , intent(in)    :: ocean_grid         !< Ocean model grid
  type(ice_ocean_boundary_type) , intent(inout) :: ice_ocean_boundary !< Ocean boundary forcing
  type(ocean_public_type)       , intent(in)    :: ocean_public       !< Ocean surface state
  integer                       , intent(in)    :: logunit            !< Unit for stdout output
  type(ESMF_Clock)              , intent(in)    :: EClock             !< Time and time step ? \todo Why must this
  real(kind=8), optional        , intent(in)    :: c1, c2, c3, c4     !< Coeffs. used in the shortwave decomposition

  ! Local variables
  integer :: i,j,isc,iec,jsc,jec,ig,jg,k  ! Grid indices
  character(*), parameter :: F01  = "('(ocn_import) ',a,4(i6,2x),d21.14)"
  !-----------------------------------------------------------------------

  ! The following are global indices without halos
  call mpp_get_compute_domain(ocean_public%domain, isc, iec, jsc, jec)

  k = 0
  do j = jsc, jec
     jg = j + ocean_grid%jsc - jsc
     do i = isc, iec
        ig = i + ocean_grid%isc - isc
        k = k + 1 ! Increment position within gindex

        ! rotate taux and tauy from true zonal/meridional to local coordinates
        ! taux
        ice_ocean_boundary%u_flux(i,j) = ocean_grid%cos_rot(ig,jg) * x2o(ind%x2o_Foxx_taux,k) &
                                       - ocean_grid%sin_rot(ig,jg) * x2o(ind%x2o_Foxx_tauy,k)

        ! tauy
        ice_ocean_boundary%v_flux(i,j) = ocean_grid%cos_rot(ig,jg) * x2o(ind%x2o_Foxx_tauy,k) &
                                       + ocean_grid%sin_rot(ig,jg) * x2o(ind%x2o_Foxx_taux,k)

        ! liquid precipitation (rain)
        ice_ocean_boundary%lprec(i,j) = x2o(ind%x2o_Faxa_rain,k)

        ! frozen precipitation (snow)
        ice_ocean_boundary%fprec(i,j) = x2o(ind%x2o_Faxa_snow,k)

        ! longwave radiation, sum up and down (W/m2)
        ice_ocean_boundary%lw_flux(i,j) = (x2o(ind%x2o_Faxa_lwdn,k) + x2o(ind%x2o_Foxx_lwup,k))

        ! specific humitidy flux
        ice_ocean_boundary%q_flux(i,j) = x2o(ind%x2o_Foxx_evap,k)

        ! sensible heat flux (W/m2)
        ice_ocean_boundary%t_flux(i,j) = x2o(ind%x2o_Foxx_sen,k)

        ! snow&ice melt heat flux (W/m^2)
        ice_ocean_boundary%seaice_melt_heat(i,j) = x2o(ind%x2o_Fioi_melth,k)

        ! water flux from snow&ice melt (kg/m2/s)
        ice_ocean_boundary%seaice_melt(i,j) = x2o(ind%x2o_Fioi_meltw,k)

        ! liquid runoff
        ice_ocean_boundary%rofl_flux(i,j) = x2o(ind%x2o_Foxx_rofl,k) * ocean_grid%mask2dT(ig,jg)

        ! ice runoff
        ice_ocean_boundary%rofi_flux(i,j) = x2o(ind%x2o_Foxx_rofi,k) * ocean_grid%mask2dT(ig,jg)

        ! surface pressure
        ice_ocean_boundary%p(i,j) = x2o(ind%x2o_Sa_pslv,k) * ocean_grid%mask2dT(ig,jg)

        ! salt flux
        ice_ocean_boundary%salt_flux(i,j) = x2o(ind%x2o_Fioi_salt,k) * ocean_grid%mask2dT(ig,jg)

        ! 1) visible, direct shortwave  (W/m2)
        ! 2) visible, diffuse shortwave (W/m2)
        ! 3) near-IR, direct shortwave  (W/m2)
        ! 4) near-IR, diffuse shortwave (W/m2)
        if (present(c1) .and. present(c2) .and. present(c3) .and. present(c4)) then
           ! Use runtime coefficients to decompose net short-wave heat flux into 4 components
           ice_ocean_boundary%sw_flux_vis_dir(i,j) = x2o(ind%x2o_Foxx_swnet,k) * c1 * ocean_grid%mask2dT(ig,jg)
           ice_ocean_boundary%sw_flux_vis_dif(i,j) = x2o(ind%x2o_Foxx_swnet,k) * c2 * ocean_grid%mask2dT(ig,jg)
           ice_ocean_boundary%sw_flux_nir_dir(i,j) = x2o(ind%x2o_Foxx_swnet,k) * c3 * ocean_grid%mask2dT(ig,jg)
           ice_ocean_boundary%sw_flux_nir_dif(i,j) = x2o(ind%x2o_Foxx_swnet,k) * c4 * ocean_grid%mask2dT(ig,jg)
        else
           ice_ocean_boundary%sw_flux_vis_dir(i,j) = x2o(ind%x2o_Faxa_swvdr,k) * ocean_grid%mask2dT(ig,jg)
           ice_ocean_boundary%sw_flux_vis_dif(i,j) = x2o(ind%x2o_Faxa_swvdf,k) * ocean_grid%mask2dT(ig,jg)
           ice_ocean_boundary%sw_flux_nir_dir(i,j) = x2o(ind%x2o_Faxa_swndr,k) * ocean_grid%mask2dT(ig,jg)
           ice_ocean_boundary%sw_flux_nir_dif(i,j) = x2o(ind%x2o_Faxa_swndf,k) * ocean_grid%mask2dT(ig,jg)
        endif

    enddo
  enddo

end subroutine ocn_import

!=======================================================================

!> Maps outgoing ocean data to MCT attribute vector real array
subroutine ocn_export(ind, ocean_public, ocean_grid, o2x, dt_int, ncouple_per_day)
  type(cpl_indices_type),  intent(inout) :: ind        !< Structure with coupler indices and vectors
  type(ocean_public_type), intent(in)    :: ocean_public !< Ocean surface state
  type(ocean_grid_type),   intent(in)    :: ocean_grid !< Ocean model grid
  real(kind=8),            intent(inout) :: o2x(:,:)   !< MCT outgoing bugger
  real(kind=8), intent(in)               :: dt_int     !< Amount of time over which to advance the
                                                       !! ocean (ocean_coupling_time_step), in sec
  integer, intent(in)                    :: ncouple_per_day !< Number of ocean coupling calls per day

  ! Local variables
  real                      :: I_time_int  !< The inverse of coupling time interval [s-1].
  integer                   :: i, j, ig, jg         ! indices
  integer                   :: isc, iec, jsc, jec   ! indices
  integer                   :: iloc, jloc           ! indices
  integer                   :: iglob, jglob         ! indices
  integer                   :: n
  integer                   :: icount
  real                      :: slp_L, slp_R, slp_C
  real                      :: slope, u_min, u_max
  integer                   :: day, secs
  real                      :: inv_dt_int  !< The inverse of coupling time interval in s-1.
  real(KIND=8), allocatable :: omask(:,:)
  real(KIND=8), allocatable :: melt_potential(:,:)
  real(KIND=8), allocatable :: ocz(:,:), ocm(:,:)
  real(KIND=8), allocatable :: ocz_rot(:,:), ocm_rot(:,:)
  real(KIND=8), allocatable :: ssh(:,:)
  real(KIND=8), allocatable :: dhdx(:,:), dhdy(:,:)
  real(KIND=8), allocatable :: dhdx_rot(:,:), dhdy_rot(:,:)
  !-----------------------------------------------------------------------

  ! Use Adcroft's rule of reciprocals; it does the right thing here.
  I_time_int = 0.0 ; if (dt_int > 0.0) I_time_int = 1.0 / dt_int

  call mpp_get_compute_domain(ocean_public%domain, isc, iec, jsc, jec)

  ! Copy from ocean_public to o2x. ocean_public uses global indexing with no halos.
  ! The mask comes from "grid" that uses the usual MOM domain that has halos
  ! and does not use global indexing.

  n = 0
  do j = jsc, jec
     jg = j + ocean_grid%jsc - jsc
     do i = isc, iec
        ig = i + ocean_grid%isc - isc
        n = n+1

        ! surface temperature in Kelvin
        o2x(ind%o2x_So_t, n) = ocean_public%t_surf(i,j) * ocean_grid%mask2dT(ig,jg)

        ! salinity
        o2x(ind%o2x_So_s, n) = ocean_public%s_surf(i,j) * ocean_grid%mask2dT(ig,jg)

        ! rotate ocn current from local tripolar grid to true zonal/meridional (inverse transformation)
        o2x(ind%o2x_So_u, n) = (ocean_grid%cos_rot(ig,jg) * ocean_public%u_surf(i,j) + &
                                ocean_grid%sin_rot(ig,jg) * ocean_public%v_surf(i,j)) * ocean_grid%mask2dT(ig,jg)
        o2x(ind%o2x_So_v, n) = (ocean_grid%cos_rot(ig,jg) * ocean_public%v_surf(i,j) - &
                                ocean_grid%sin_rot(ig,jg) * ocean_public%u_surf(i,j)) * ocean_grid%mask2dT(ig,jg)

        ! boundary layer depth (m)
        o2x(ind%o2x_So_bldepth, n) = ocean_public%OBLD(i,j) * ocean_grid%mask2dT(ig,jg)

        if (ocean_public%frazil(i,j) > 0.0) then
           ! Frazil: change from J/m^2 to W/m^2
           o2x(ind%o2x_Fioo_q, n) = ocean_public%frazil(i,j) * ocean_grid%mask2dT(ig,jg) * I_time_int
        else
           ! Melt_potential: change from J/m^2 to W/m^2
           o2x(ind%o2x_Fioo_q, n) = -ocean_public%melt_potential(i,j) * ocean_grid%mask2dT(ig,jg) * I_time_int !* ncouple_per_day
           ! make sure Melt_potential is always <= 0
           if (o2x(ind%o2x_Fioo_q, n) > 0.0) o2x(ind%o2x_Fioo_q, n) = 0.0
        endif

     enddo
  enddo

  !----------------
  ! Sea-surface zonal and meridional slopes
  !----------------

  allocate(ssh(ocean_grid%isd:ocean_grid%ied,ocean_grid%jsd:ocean_grid%jed)) ! local indices with halos
  allocate(dhdx(isc:iec, jsc:jec))     !global indices without halos
  allocate(dhdy(isc:iec, jsc:jec))     !global indices without halos
  allocate(dhdx_rot(isc:iec, jsc:jec)) !global indices without halos
  allocate(dhdy_rot(isc:iec, jsc:jec)) !global indices without halos

  ! Make a copy of ssh in order to do a halo update (ssh has local indexing with halos)
  do j = ocean_grid%jsc, ocean_grid%jec
     jloc = j + ocean_grid%jdg_offset
     do i = ocean_grid%isc,ocean_grid%iec
        iloc = i + ocean_grid%idg_offset
        ssh(i,j) = ocean_public%sea_lev(iloc,jloc)
     enddo
  enddo

  ! Update halo of ssh so we can calculate gradients
  call pass_var(ssh, ocean_grid%domain)

  ! d/dx ssh
  ! This is a simple second-order difference
  ! dhdx(i,j) = 0.5 * (ssh(i+1,j) - ssh(i-1,j)) * ocean_grid%IdxT(i,j) * ocean_grid%mask2dT(ig,jg)

  do jglob = jsc, jec
    j  = jglob + ocean_grid%jsc - jsc
    do iglob = isc,iec
      i  = iglob + ocean_grid%isc - isc
      ! This is a PLM slope which might be less prone to the A-grid null mode
      slp_L = (ssh(I,j) - ssh(I-1,j)) * ocean_grid%mask2dCu(i-1,j)
      if (ocean_grid%mask2dCu(i-1,j)==0.) slp_L = 0.
      slp_R = (ssh(I+1,j) - ssh(I,j)) * ocean_grid%mask2dCu(i,j)
      if (ocean_grid%mask2dCu(i+1,j)==0.) slp_R = 0.
      slp_C = 0.5 * (slp_L + slp_R)
      if ( (slp_L * slp_R) > 0.0 ) then
        ! This limits the slope so that the edge values are bounded by the
        ! two cell averages spanning the edge.
        u_min = min( ssh(i-1,j), ssh(i,j), ssh(i+1,j) )
        u_max = max( ssh(i-1,j), ssh(i,j), ssh(i+1,j) )
        slope = sign( min( abs(slp_C), 2.*min( ssh(i,j) - u_min, u_max - ssh(i,j) ) ), slp_C )
      else
        ! Extrema in the mean values require a PCM reconstruction avoid generating
        ! larger extreme values.
        slope = 0.0
      endif
      dhdx(iglob,jglob) = slope * ocean_grid%IdxT(i,j) * ocean_grid%mask2dT(i,j)
      if (ocean_grid%mask2dT(i,j)==0.) dhdx(iglob,jglob) = 0.0
    enddo
  enddo

  ! d/dy ssh
  ! This is a simple second-order difference
  ! dhdy(i,j) = 0.5 * (ssh(i,j+1) - ssh(i,j-1)) * ocean_grid%IdyT(i,j) * ocean_grid%mask2dT(ig,jg)

  do jglob = jsc, jec
    j = jglob + ocean_grid%jsc - jsc
    do iglob = isc,iec
       i = iglob + ocean_grid%isc - isc
      ! This is a PLM slope which might be less prone to the A-ocean_grid null mode
      slp_L = ssh(i,J) - ssh(i,J-1) * ocean_grid%mask2dCv(i,j-1)
      if (ocean_grid%mask2dCv(i,j-1)==0.) slp_L = 0.
      slp_R = ssh(i,J+1) - ssh(i,J) * ocean_grid%mask2dCv(i,j)
      if (ocean_grid%mask2dCv(i,j+1)==0.) slp_R = 0.
      slp_C = 0.5 * (slp_L + slp_R)
      if ((slp_L * slp_R) > 0.0) then
        ! This limits the slope so that the edge values are bounded by the
        ! two cell averages spanning the edge.
        u_min = min( ssh(i,j-1), ssh(i,j), ssh(i,j+1) )
        u_max = max( ssh(i,j-1), ssh(i,j), ssh(i,j+1) )
        slope = sign( min( abs(slp_C), 2.*min( ssh(i,j) - u_min, u_max - ssh(i,j) ) ), slp_C )
      else
        ! Extrema in the mean values require a PCM reconstruction avoid generating
        ! larger extreme values.
        slope = 0.0
      endif
      dhdy(iglob,jglob) = slope * ocean_grid%IdyT(i,j) * ocean_grid%mask2dT(i,j)
      if (ocean_grid%mask2dT(i,j)==0.) dhdy(iglob,jglob) = 0.0
    enddo
  enddo

  ! rotate slopes from tripolar grid back to lat/lon grid,  x,y => latlon (CCW)
  ! "ocean_grid" uses has halos and uses local indexing.

  n = 0
  do j = jsc, jec
     jg = j + ocean_grid%jsc - jsc
     do i = isc, iec
        ig = i + ocean_grid%isc - isc
        n = n + 1
        o2x(ind%o2x_So_dhdx, n) = ocean_grid%cos_rot(ig,jg)*dhdx(i,j) + ocean_grid%sin_rot(ig,jg)*dhdy(i,j)
        o2x(ind%o2x_So_dhdy, n) = ocean_grid%cos_rot(ig,jg)*dhdy(i,j) - ocean_grid%sin_rot(ig,jg)*dhdx(i,j)
     enddo
  enddo

  deallocate(ssh, dhdx, dhdy, dhdx_rot, dhdy_rot)

end subroutine ocn_export

end module ocn_cap_methods
