--use of update command 
update PatientMaster set Mobile='NA', EnquiryId=001, ClinicID=7, FName='Deesha', RegistrationDate=GETDATE() where Mobile is null and ClinicID=7
update PatientMaster set Age=0 where Mobile='NA' and ClinicID=7




--use of subqueries to see result without null and blank address where pateint have paid some amount
Select * From tbl_ClinicDetails where ClinicID in (Select ClinicID From InvoiceMaster where PaidAmount >0)
and AddressLine1 is not null and AddressLine1 !=''


--finding total paid amount, pending amount and % of pending amount using join of specific Patient
	Select PM.Fname+' '+PM.Lastname [Patient Name], IM.GrandTotal, Sum(IM.PaidAMount) [Paid Amount],
	(IM.GrandTotal) - Sum(IM.PaidAmount) [Pending Amount],((((IM.GrandTotal)- Sum(IM.PaidAmount))/(IM.GrandTotal)*100))[Pending Amount Percentage]
	From PatientMaster PM
	left join InvoiceMaster IM on IM.patientid=PM.patientid 
	where PM.patientid=13
	Group by PM.Fname,PM.LastName,IM.GrandTotal


--Created stored procedure to get value from the given statement

CREATE PROCEDURE SP_GetPatientDetails
@clinicId int,
@PatientName nvarchar(200)
AS
BEGIN
	select * from PatientMaster where 
	IsActive=1 and clinicId=@clinicId and Fname like '%'+@PatientName+'%'
END	
GO

Exec SP_GetPatientDetails @clinicId=7,@PatientName='a'


--Used Alter Stored procedure with wild cards to get patient details
Alter PROCEDURE SP_GetPatientDetails
@clinicId int,
@PatientName nvarchar(200),
@FAge int,
@TAge int
AS
BEGIN
	select * from PatientMaster where 
	IsActive=1 and clinicId=@clinicId and Fname like '%'+@PatientName+'%' and Age BETWEEN  @FAge and @TAge
END	
GO

Exec SP_GetPatientDetails @clinicId=7,@PatientName='Me',@FAge=25,@TAge=35




--Created Stored procedure to insert the new patient details in the table
Create Procedure [dbo].[Set_Patient]
(
 @Cid int,
 @Fname Nvarchar(100),
 @LastName nvarchar(100),
 @Age int
)
as 
begin
 
 insert into PatientMaster(FName,LastName,ClinicID,Age,IsActive)
 values(@Fname,@LastName,@Cid,@Age,1)
	
END

Exec Set_Patient  @Cid=7,@Fname='MAC',@LastName='Rana',@Age=30


--Created Stored procedure to get specific paid amount and pending amount with alongwith doctorname


Create Procedure [dbo].[GET_DoctorPaidAmount]
(
@Dcname nvarchar(100),
@DoctorID int,
@FPaidAmount int,
@TPaidAmount int
)
as 
begin

  Select DD.FirstName+' '+DD.LastName [Doctor Name], IM.GrandTotal, Sum(IM.PaidAMount) [Paid Amount],
(IM.GrandTotal) - Sum(IM.PaidAmount) [Pending Amount],((((IM.GrandTotal)- Sum(IM.PaidAmount))/(IM.GrandTotal)*100))[Pending Amount Percentage]
From tbl_DoctorDetails DD
left join InvoiceMaster IM on IM.DoctorID=DD.DoctorID 

 and
	( 
	  @Dcname='' OR FirstName like '%'+@Dcname+'%'
	) 
	
and
    ( 
	   @DoctorID='0' OR IM.DoctorID =@DoctorID 
     )
	
	Group by DD.FirstName,DD.LastName,IM.GrandTotal

	having
	(@FPaidAmount='' Or Sum(im.PaidAmount) BETWEEN  @FPaidAmount and @TPaidAmount)
END

Exec GET_DoctorPaidAmount @Dcname='',@DoctorID=0,@FPaidAmount =80000,@TPaidAmount=1000000