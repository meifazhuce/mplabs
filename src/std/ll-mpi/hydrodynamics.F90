!-------------------------------------------------------------------------------
! Subroutine : Hydrodynamics
! Revision   : 1.0 (2008-06-15)
! Author     : Carlos Rosales Fernandez [carlos.rosales.fernandez(at)gmail.com]
!-------------------------------------------------------------------------------
!> @file
!! Calculate velocity, pressure and chemical potential using fbar and gbar
!> @details
!! Calculate the velocity, pressure, and chemical potential based on the order
!! parameter (fbar) and pressure (gbar) distribution functions after the
!! streaming step assuming periodic boundary conditions in all directions for
!! the parallel D2Q9 Lee-Lin multiphase LBM.

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

 SUBROUTINE Hydrodynamics

! Common Variables
 USE NTypes,    ONLY : DBL
 USE Domain,    ONLY : inv12, ni, xl, xlg, xlg2, xu, xug, xug2, yl, ylg, ylg2, yu, yug, yug2
 USE FluidParams
 USE LBMParams, ONLY : Cs_sq, gbar
 IMPLICIT NONE

! Local Variables
 INTEGER :: i, j, ie, iw, jn, js
 REAL(KIND = DBL) :: invrho, gradRhoSqX, gradRhoSqY
 REAL(KIND = DBL) :: gradRhoXX2, gradRhoXY2, gradRhoYX2, gradRhoYY2, lapRho


!--------- Differential terms for the stress form of the interfacial force -----
 DO j = ylg, yug
   DO i = xlg, xug

! Identify first neighbors
     ie = ni(i,j,1)
     jn = ni(i,j,2)
     iw = ni(i,j,3)
     js = ni(i,j,4)

! Gradient of the density rho
     gradRhoX(i,j) = ( 4.D0*( rho(ie,j ) - rho(iw,j ) ) + rho(ie,jn) &
                   - rho(iw,js) + rho(ie,js) - rho(iw,jn) )*inv12

     gradRhoY(i,j) = ( 4.D0*( rho(i ,jn) - rho(i ,js) ) + rho(ie,jn) &
                   - rho(iw,js) + rho(iw,jn) - rho(ie,js) )*inv12

! Square of the density gradient (components and full)
     gradRhoXX(i,j) = gradRhoX(i,j)*gradRhoX(i,j)
     gradRhoXY(i,j) = gradRhoX(i,j)*gradRhoY(i,j)
     gradRhoYY(i,j) = gradRhoY(i,j)*gradRhoY(i,j)
     gradRhoSq(i,j) = gradRhoXX(i,j) + gradRhoYY(i,j)

   END DO
 END DO

!--------- Differential terms for the potential form of the interfacial force --
 DO j = ylg2, yug2
   DO i = xlg2, xug2

! Identify first neighbors
     ie = ni(i,j,1)
     jn = ni(i,j,2)
     iw = ni(i,j,3)
     js = ni(i,j,4)

! Laplacian of the density rho
     lapRho = 4.D0*( rho(ie,j ) + rho(iw,j ) + rho(i ,jn) + rho(i ,js) ) &
            + rho(ie,jn) + rho(ie,js) + rho(iw,jn) + rho(iw,js) - 20.D0*rho(i,j)

! Define chemical potential Psi
     psi(i,j) = beta4*( rho(i,j) - rhoStar )*( rho(i,j) - rhoL )*( rho(i,j) - rhoH ) &
              - kappa_6*lapRho

   END DO
 END DO

!--------- Velocity Calculation ------------------------------------------------
 DO j = yl, yu
   DO i = xl, xu

   invrho = 1.D0/rho(i,j)

! Identify neighboring cells
     ie = ni(i,j,1)
     jn = ni(i,j,2)
     iw = ni(i,j,3)
     js = ni(i,j,4)

! Gradient of the square of the density gradient
     gradRhoSqX = 4.D0*( gradRhoSq(ie,j ) - gradRhoSq(iw,j ) ) &
                + gradRhoSq(ie,jn) - gradRhoSq(iw,jn)          &
                + gradRhoSq(ie,js) - gradRhoSq(iw,js)

     gradRhoSqY = 4.D0*( gradRhoSq(i ,jn) - gradRhoSq(i ,js) ) &
                + gradRhoSq(ie,jn) - gradRhoSq(ie,js)          &
                + gradRhoSq(iw,jn) - gradRhoSq(iw,js)

! Second derivatives of rho
     gradRhoXX2 = 4.D0*( gradRhoXX(ie,j ) - gradRhoXX(iw,j ) ) &
                + gradRhoXX(ie,jn) - gradRhoXX(iw,js)          &
                + gradRhoXX(ie,js) - gradRhoXX(iw,jn)

     gradRhoXY2 = 4.D0*( gradRhoXY(i ,jn) - gradRhoXY(i ,js) ) &
                + gradRhoXY(ie,jn) - gradRhoXY(iw,js)          &
                + gradRhoXY(iw,jn) - gradRhoXY(ie,js)

     gradRhoYX2 = 4.D0*( gradRhoXY(ie,j ) - gradRhoXY(iw,j ) ) &
                + gradRhoXY(ie,jn) - gradRhoXY(iw,js)          &
                + gradRhoXY(ie,js) - gradRhoXY(iw,jn)

     gradRhoYY2 = 4.D0*( gradRhoYY(i ,jn) - gradRhoYY(i ,js) ) &
                + gradRhoYY(ie,jn) - gradRhoYY(iw,js)          &
                + gradRhoYY(iw,jn) - gradRhoYY(ie,js)
 
! Velocity calculation
     u(i,j,1) = invrho*( gbar(i,j,1) - gbar(i,j,3) + gbar(i,j,5) - gbar(i,j,6) &
              - gbar(i,j,7) + gbar(i,j,8) + 0.5D0*kappa_12*( gradRhoSqX        &
              - gradRhoXX2 - gradRhoXY2 ) )

     u(i,j,2) = invrho*( gbar(i,j,2) - gbar(i,j,4) + gbar(i,j,5) + gbar(i,j,6) &
              - gbar(i,j,7) - gbar(i,j,8) + 0.5D0*kappa_12*( gradRhoSqY        &
              - gradRhoYX2 - gradRhoYY2 ) )

   END DO
 END DO

!--------- Pressure calculation ------------------------------------------------
 DO j = yl, yu
   DO i = xl, xu
     p(i,j) = Cs_sq*( gbar(i,j,0) + gbar(i,j,1) + gbar(i,j,2) + gbar(i,j,3)       &
            + gbar(i,j,4) + gbar(i,j,5) + gbar(i,j,6) + gbar(i,j,7) + gbar(i,j,8) &
            + 0.5D0*( u(i,j,1)*gradRhoX(i,j) + u(i,j,2)*gradRhoY(i,j) ) )
   END DO
 END DO

 RETURN
 END SUBROUTINE Hydrodynamics
