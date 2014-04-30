SELECT
ges.fein,
xs.dcas_01 as hbx_id,
--gep.enrollment_period_ext_id as employer_enrollment_id,
ges.doing_business_as as name,
xs.ahi_01, xs.ddpa_01, xs.dmnd_01, xs.dtga_01, xs.gard_01, xs.ghmsi_01, xs.kfmasi_01, xs.meta_01, xs.uhic_01, xs.blhi_01
FROM GPA_ENROLLMENT_PERIOD gep join GPA_ER_SETUP ges on gep.er_setup_id = ges.er_setup_id
join GPA_COMPANY gc on gc.company_id = ges.company_id
right outer join DCASESB_SOAINFRA.XREF_SPONSOR xs on xs.CARR_01 = ges.fein
where coalesce(xs.ahi_01, xs.ddpa_01, xs.dmnd_01, xs.dtga_01, xs.gard_01, xs.ghmsi_01, xs.kfmasi_01, xs.meta_01, xs.uhic_01, xs.blhi_01) is not null