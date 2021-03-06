!-------------------------------------------------------------------------------
! File     : Common
! Revision : 1.0 (2008-06-15)
! Author   : David S. Whyte [david(at)ihpc.a-star.edu.sg]
!-------------------------------------------------------------------------------
!> @file
!! Modules that contain common variables

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

!> @brief Definition of single and double data types
 MODULE NTypes
 IMPLICIT NONE
 SAVE

 INTEGER, PARAMETER :: SGL = KIND(1.0)
 INTEGER, PARAMETER :: DBL = KIND(1.D0)

 END MODULE NTypes

!> @brief Parameters related to the geometry and the time intervals
 MODULE Domain
 USE NTypes, ONLY : DBL
 IMPLICIT NONE
 SAVE

! Maximum time of steps and data dump times
 INTEGER :: MaxStep, RelaxStep, iStep, tCall, tDump, tStat

! Domain size
! ndim = spatial dimension
 INTEGER, PARAMETER :: ndim = 2
 INTEGER :: xmin, xmax, ymin, ymax
 INTEGER :: now, nxt, NX, NY

! Neighbour array
 INTEGER, ALLOCATABLE, DIMENSION(:,:,:) :: ni

! Effective volume and radius
 REAL(KIND = DBL) :: invInitVol

! Define constants used in the code (inv6 = 1/6, inv12 = 1/12, invPi = 1/pi)
 REAL(KIND = DBL), PARAMETER :: inv6  = 0.16666666666666666667D0
 REAL(KIND = DBL), PARAMETER :: inv12 = 0.08333333333333333333D0
 REAL(KIND = DBL), PARAMETER :: invPi = 0.31830988618379067154D0

 END MODULE Domain

!> @brief Parameters related to hydrodynamics quantities
 MODULE FluidParams
 USE NTypes, ONLY : DBL
 IMPLICIT NONE
 SAVE

! Convergence analysis
 REAL(KIND = DBL) :: eps, pConv
 REAL(KIND = DBL), DIMENSION(1:11) :: Convergence

! Discrete phase
 INTEGER :: nBubbles
 REAL(KIND = DBL), ALLOCATABLE, DIMENSION(:,:) :: bubbles

! Interface and chemical potential
 REAL(KIND = DBL) :: Gamma, sigma, IntWidth
 REAL(KIND = DBL) :: alpha, alpha4, kappa, kappa_6

! Hydrodynamics
 REAL(KIND = DBL) :: rhoL, rhoH, tauRho, invTauRho, invTauRho2
 REAL(KIND = DBL) :: phiStar, phiStar2, phiStar4, tauPhi, invTauPhi
 REAL(KIND = DBL) :: eta, eta2, invEta2
 REAL(KIND = DBL), ALLOCATABLE, DIMENSION(:,:)   :: phi
 REAL(KIND = DBL), ALLOCATABLE, DIMENSION(:,:)   :: p
 REAL(KIND = DBL), ALLOCATABLE, DIMENSION(:,:,:) :: u

 END MODULE FluidParams

!> @brief Parameters related to the LBM discretization
 MODULE LBMParams
 USE NTypes, ONLY : DBL
 IMPLICIT NONE
 SAVE

! fdim = order parameter distribution dimension - 1 (D2Q5)
! gdim = momentum distribution dimension - 1 (D2Q9)
 INTEGER, PARAMETER :: fdim = 4
 INTEGER, PARAMETER :: gdim = 8

! Distribution functions
 REAL(KIND = DBL), ALLOCATABLE, DIMENSION(:,:,:,:) :: f, g

! D2Q9 Lattice speed of sound (Cs = 1/DSQRT(3), Cs_sq = 1/3, invCs_sq = 3)
 REAL(KIND = DBL), PARAMETER :: Cs       = 0.57735026918962576451D0
 REAL(KIND = DBL), PARAMETER :: Cs_sq    = 0.33333333333333333333D0
 REAL(KIND = DBL), PARAMETER :: invCs_sq = 3.00000000000000000000D0

! Distributions weights (D2Q9: Eg0 = 4/9, Eg1 = 1/9, Eg2 = 1/36)
 REAL(KIND = DBL), PARAMETER :: Eg0 = 0.44444444444444444444D0
 REAL(KIND = DBL), PARAMETER :: Eg1 = 0.11111111111111111111D0
 REAL(KIND = DBL), PARAMETER :: Eg2 = 0.02777777777777777778D0

! Modified distribution weight (to avoid operations: EgiC = Egi*invCs_sq)
 REAL(KIND = DBL), PARAMETER :: Eg0C = 1.33333333333333333333D0
 REAL(KIND = DBL), PARAMETER :: Eg1C = 0.33333333333333333333D0
 REAL(KIND = DBL), PARAMETER :: Eg2C = 0.08333333333333333333D0
 REAL(KIND = DBL) :: Eg0T, Eg1T, Eg2T

 END MODULE LBMParams


