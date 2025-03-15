

drop table if exists #Departments


select * 
into #Departments
from (
	select dh.BusinessEntityID, 
			dh.DepartmentID, 
			dh.ShiftID,
			dh.StartDate,
			dh.EndDate,
			dh.ModifiedDate,
			d.Name as DepartmentName,
			d.GroupName,
			row_number() over(partition by dh.BusinessEntityID order by dh.ModifiedDate desc) as rnk

	from [HumanResources].[EmployeeDepartmentHistory] dh
	left join [HumanResources].[Department] d on d.DepartmentID = dh.DepartmentID
	 ) a;





with EmployeePay as (

select emp.BusinessEntityID,
	   emp.NationalIDNumber,
	   emp.LoginID,
	   emp.OrganizationNode,
	   emp.OrganizationLevel,
	   emp.JobTitle,
	   emp.BirthDate,
	   emp.MaritalStatus,
	   emp.Gender,
	   emp.HireDate,
	   emp.SalariedFlag,
	   emp.VacationHours,
	   emp.SickLeaveHours,
	   emp.CurrentFlag,
	   emp.rowguid,
	   emp.ModifiedDate,
	   eph.Rate,
	   d.DepartmentName,
	   d.GroupName,
	   row_number() over(partition by d.DepartmentName order by eph.Rate desc) as salaryrank
	   
from [HumanResources].[Employee] emp
left join  (select * 
			from (
					select BusinessEntityID, 
							RateChangeDate,
							Rate,
							PayFrequency,
							ModifiedDate,
							row_number() over(partition by BusinessEntityID order by ModifiedDate desc) as rnk
					from HumanResources.EmployeePayHistory
				  ) a
			where rnk = 1
			) eph on emp.BusinessEntityID = eph.BusinessEntityID
left join #Departments d on emp.BusinessEntityID = d.BusinessEntityID
where emp.SalariedFlag = 1

				)

				select *
				from EmployeePay
				where salaryrank in (1,2,3)
				order by DepartmentName, Rate desc;

