!-------------------------------------------------------------------------------
! Subroutine : Differentials
! Revision   : 1.0 (2008-06-15)
! Author     : Carlos Rosales Fernandez [carlos.rosales.fernandez(at)gmail.com]
!-------------------------------------------------------------------------------
!> @file
!! Order parameter calculation and differential terms for the interfacial force.
!> @details
!! Calculate the order parameter phi_f using updated values of the distribution
!! function f and then obtain the differential terms necessary for the
!! interfacial force calculation (the Laplacian and the gradient of the order
!! parameter phi_f) in the dual grid D2Q5/D2Q9 Zheng-Shu-Chew multiphase LBM.
!! The calculation is done directly on the order parameter grid.

!-------------------------------------------------------------------------------
! Copyright 2008 Carlos Rosales Fernandez, David S. Whyte and IHPC (A*STAR).
!
! This file is part of MP-LABS.
!
! MP-LABS is free software: you can redistribute it and/or modify it under the
! terms of the GNU GPL version 3 or (at your option) any later version.
!
! MP-LABS is distributed in the hope that it will be useful, but WITHOUT ANY
! WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
! A PARTICULAR PURPOSE. See the GNU General Public License for more details.
!
! You should have received a copy of the GNU General Public License along with
! MP-LABS, in the file COPYING.txt. If not, see <http://www.gnu.org/licenses/>.
!-------------------------------------------------------------------------------

 SUBROUTINE Differentials

! Common Variables
 USE Domain,      ONLY : inv12, inv6, ni_f, xmax_f, xmin_f, ymax_f, ymin_f
 USE FluidParams, ONLY : gradPhiX_f, gradPhiY_f, lapPhi_f, phi_f
 USE LBMParams,   ONLY : f
 IMPLICIT NONE

! Local Variables
 INTEGER :: i, j, ie, iw, jn, js

! Order parameter
 DO j = ymin_f, ymax_f
   DO i = xmin_f, xmax_f
     phi_f(i,j) = f(i,j,0) + f(i,j,1) + f(i,j,2) + f(i,j,3) + f(i,j,4)
   END DO
 END DO

! Differentials needed for the interfacial terms 
 DO j = ymin_f, ymax_f
   DO i = xmin_f, xmax_f

     ie = ni_f(i,j,1)
     jn = ni_f(i,j,2)
     iw = ni_f(i,j,3)
     js = ni_f(i,j,4)

! Laplacian
     lapPhi_f(i,j) = ( phi_f(ie,jn) + phi_f(ie,js) + phi_f(iw,jn)          &
                   + phi_f(iw,js) + 4.D0*( phi_f(ie,j) + phi_f(iw,j)       &
                   + phi_f(i,jn) + phi_f(i,js) ) - 20.D0*phi_f(i,j) )*inv6
! Gradients
     gradPhiX_f(i,j)  = ( 4.D0*( phi_f(ie,j) - phi_f(iw,j) ) + phi_f(ie,jn) &
                      - phi_f(iw,js) + phi_f(ie,js) - phi_f(iw,jn) )*inv12

     gradPhiY_f(i,j)  = ( 4.D0*( phi_f(i,jn) - phi_f(i,js) ) + phi_f(ie,jn) &
                      - phi_f(iw,js) - phi_f(ie,js) + phi_f(iw,jn) )*inv12

   END DO
 END DO

 RETURN
 END SUBROUTINE Differentials

