package org.openmrs.module.ipdapp.fragment.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.type.TypeFactory;
import org.apache.commons.collections.CollectionUtils;
import org.apache.commons.lang.ArrayUtils;
import org.apache.commons.lang.StringUtils;
import org.codehaus.jackson.JsonParseException;
import org.codehaus.jackson.map.JsonMappingException;
import org.openmrs.*;
import org.openmrs.api.AdministrationService;
import org.openmrs.api.ConceptService;
import org.openmrs.api.PatientService;
import org.openmrs.api.context.Context;
import org.openmrs.module.hospitalcore.*;
import org.openmrs.module.hospitalcore.model.*;
import org.openmrs.module.hospitalcore.util.ConceptComparator;
import org.openmrs.module.hospitalcore.util.PatientDashboardConstants;
import org.openmrs.module.ipdapp.model.Prescription;
import org.openmrs.module.ipdapp.model.PrescriptionList;
import org.openmrs.module.ipdapp.model.Procedure;
import org.openmrs.ui.framework.SimpleObject;
import org.openmrs.ui.framework.UiUtils;
import org.openmrs.ui.framework.page.PageModel;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.bind.annotation.RequestParam;

import java.io.IOException;
import java.lang.reflect.Type;
import java.math.BigDecimal;
import java.text.SimpleDateFormat;
import java.util.*;

/**
 *
 */
public class PatientInfoFragmentController {
    private static Logger log = LoggerFactory.getLogger(PatientInfoFragmentController.class);

    //get the list of procedures starting with a certain string
    public List<SimpleObject> getProcedures(@RequestParam(value = "q") String name, UiUtils ui) {
        List<Concept> procedures = Context.getService(PatientDashboardService.class).searchProcedure(name);
        List<Procedure> proceduresPriority = new ArrayList<Procedure>();
        for (Concept myConcept : procedures) {
            proceduresPriority.add(new Procedure(myConcept));
        }

        List<SimpleObject> proceduresList = SimpleObject.fromCollection(proceduresPriority, ui, "id", "label", "schedulable");
        return proceduresList;
    }

    public List<SimpleObject> getInvestigations(@RequestParam(value="q") String name,UiUtils ui) {
        List<Concept> investigations = Context.getService(PatientDashboardService.class).searchInvestigation(name);
        List<SimpleObject> investigationsList = SimpleObject.fromCollection(investigations, ui, "id", "name");
        return investigationsList;
    }

    public List<SimpleObject> getDrugs(@RequestParam(value="q") String name,UiUtils ui) {
        List<InventoryDrug> drugs = Context.getService(PatientDashboardService.class).findDrug(name);
        List<SimpleObject> drugList = SimpleObject.fromCollection(drugs, ui, "id", "name");
        return drugList;
    }

    public List<SimpleObject> getFormulationByDrugName(@RequestParam(value="drugName") String drugName,UiUtils ui) {

        InventoryCommonService inventoryCommonService = (InventoryCommonService) Context.getService(InventoryCommonService.class);
        InventoryDrug drug = inventoryCommonService.getDrugByName(drugName);

        List<SimpleObject> formulationsList = null;

        if(drug != null){
            List<InventoryDrugFormulation> formulations = new ArrayList<InventoryDrugFormulation>(drug.getFormulations());
            formulationsList = SimpleObject.fromCollection(formulations, ui, "id", "name", "dozage");
        }

        return formulationsList;
    }

    public List<SimpleObject> getDiagnosis(@RequestParam(value="q") String name,UiUtils ui) {
        List<Concept> diagnosis = Context.getService(PatientDashboardService.class).searchDiagnosis(name);

        List<SimpleObject> diagnosisList = SimpleObject.fromCollection(diagnosis, ui, "id", "name");
        return diagnosisList;
    }
    
    public void requestForDischarge(@RequestParam(value = "id", required = false) Integer admittedId,
                                    @RequestParam(value = "ipdWard", required = false) String ipdWard,
                                    @RequestParam(value = "obStatus", required = false) Integer obStatus) {

        int requestForDischargeStatus = 1;
        IpdService ipdService = (IpdService) Context.getService(IpdService.class);
        IpdPatientAdmitted admitted = ipdService.getIpdPatientAdmitted(admittedId);
        IpdPatientAdmissionLog ipal = admitted.getPatientAdmissionLog();

        admitted.setRequestForDischargeStatus(requestForDischargeStatus);
        admitted.setAbsconded(obStatus);

        ipal.setRequestForDischargeStatus(requestForDischargeStatus);
        ipal.setAbsconded(obStatus);

        if(obStatus == 1){
            Date date = new Date();
            admitted.setAbscondedDate(date);
        }
        admitted = ipdService.saveIpdPatientAdmitted(admitted);
        ipal = ipdService.saveIpdPatientAdmissionLog(ipal);
    }

    public void transferPatient(@RequestParam("admittedId") Integer id,
                                @RequestParam("toWard") Integer toWardId,
                                @RequestParam("doctor") Integer doctorId,
                                @RequestParam(value = "bedNumber", required = false) String bed,
                                @RequestParam(value = "comments", required = false) String comments,
                                PageModel model){
        IpdService ipdService = (IpdService) Context.getService(IpdService.class);
        ipdService.transfer(id, toWardId, doctorId, bed,comments);

    }
    public void saveVitalStatistics(@RequestParam("admittedId") Integer admittedId,
                                    @RequestParam("patientId") Integer patientId,
                                    @RequestParam(value = "systolicBloodPressure", required = false) String systolicBloodPressure,
                                    @RequestParam(value = "diastolicBloodPressure", required = false) String diastolicBloodPressure,
                                    @RequestParam(value = "pulseRate", required = false) String pulseRate,
                                    @RequestParam(value = "temperature", required = false) String temperature,
                                    @RequestParam(value = "dietAdvised", required = false) String dietAdvised,
                                    @RequestParam(value = "notes", required = false) String notes,
                                    @RequestParam(value = "ipdWard", required = false) String ipdWard,PageModel model)
    {
        IpdService ipdService = (IpdService) Context.getService(IpdService.class);
        PatientService patientService = Context.getPatientService();
        Patient patient = patientService.getPatient(patientId);
        IpdPatientAdmitted admitted = ipdService.getIpdPatientAdmitted(admittedId);
        IpdPatientVitalStatistics ipdPatientVitalStatistics=new IpdPatientVitalStatistics();
        ipdPatientVitalStatistics.setPatient(patient);
        ipdPatientVitalStatistics.setIpdPatientAdmissionLog(admitted.getPatientAdmissionLog());
        ipdPatientVitalStatistics.setSystolicBloodPressure(systolicBloodPressure);
        ipdPatientVitalStatistics.setDiastolicBloodPressure(diastolicBloodPressure);
        ipdPatientVitalStatistics.setPulseRate(pulseRate);
        ipdPatientVitalStatistics.setTemperature(temperature);
        ipdPatientVitalStatistics.setDietAdvised(dietAdvised);
        ipdPatientVitalStatistics.setNote(notes);
        ipdPatientVitalStatistics.setCreator(Context.getAuthenticatedUser().getUserId());
        ipdPatientVitalStatistics.setCreatedOn(new Date());
        ipdService.saveIpdPatientVitalStatistics(ipdPatientVitalStatistics);
    }
    public void dischargePatient( @RequestParam(value ="dischargeAdmittedID", required = false) Integer dischargeAdmittedID,
                                  @RequestParam(value ="patientId", required = false) Integer patientId,
                                  @RequestParam(value ="selectedDiagnosisList[]", required = false) Integer[] selectedDiagnosisList,
                                  @RequestParam(value ="selectedDischargeProcedureList[]", required = false) Integer[] selectedDischargeProcedureList,
                                  @RequestParam(value ="dischargeOutcomes", required = false) Integer dischargeOutcomes,
                                  @RequestParam(value ="otherDischargeInstructions", required = false) String otherDischargeInstructions
    ){

        HospitalCoreService hospitalCoreService = (HospitalCoreService) Context.getService(HospitalCoreService.class);
        PatientQueueService queueService = Context.getService(PatientQueueService.class);
        PatientSearch patientSearch = hospitalCoreService.getPatient(patientId);

        IpdService ipdService = (IpdService) Context.getService(IpdService.class);

        if (Context.getConceptService().getConcept(dischargeOutcomes).getName().getName().equalsIgnoreCase("DEATH")) {

            ConceptService conceptService = Context.getConceptService();
            Concept causeOfDeath = conceptService.getConceptByName("NONE");
            hospitalCoreService.savePatientSearch(patientSearch);
            PatientService ps=Context.getPatientService();
            Patient patient = ps.getPatient(patientId);
            patient.setDead(true);
            patient.setDeathDate(new Date());
            patient.setCauseOfDeath(causeOfDeath);
            ps.savePatient(patient);
            patientSearch.setDead(true);
            patientSearch.setAdmitted(false);
            hospitalCoreService.savePatientSearch(patientSearch);
        }
        else{
            patientSearch.setAdmitted(false);
            hospitalCoreService.savePatientSearch(patientSearch);
        }

        AdministrationService administrationService = Context.getAdministrationService();
        GlobalProperty gpDiagnosis = administrationService
                .getGlobalPropertyObject(PatientDashboardConstants.PROPERTY_PROVISIONAL_DIAGNOSIS);
        GlobalProperty procedure = administrationService
                .getGlobalPropertyObject(PatientDashboardConstants.PROPERTY_POST_FOR_PROCEDURE);
        ConceptService conceptService = Context.getConceptService();
        Concept cDiagnosis = conceptService.getConceptByName(gpDiagnosis.getPropertyValue());
        Concept cProcedure = conceptService.getConceptByName(procedure.getPropertyValue());
        IpdPatientAdmitted admitted = ipdService.getIpdPatientAdmitted(dischargeAdmittedID);
        Encounter ipdEncounter = admitted.getPatientAdmissionLog().getIpdEncounter();
        List<Obs> listObsOfIpdEncounter = new ArrayList<Obs>(ipdEncounter.getAllObs());
        Location location = new Location(1);

        User user = Context.getAuthenticatedUser();
        Date date = new Date();
        //diagnosis

        Set<Obs> obses = new HashSet(ipdEncounter.getAllObs());

        ipdEncounter.setObs(null);

        List<Concept> listConceptDianosisOfIpdEncounter = new ArrayList<Concept>();
        List<Concept> listConceptProcedureOfIpdEncounter = new ArrayList<Concept>();
        if (CollectionUtils.isNotEmpty(listObsOfIpdEncounter)) {
            for (Obs obx : obses) {
                if (obx.getConcept().getConceptId().equals(cDiagnosis.getConceptId())) {
                    listConceptDianosisOfIpdEncounter.add(obx.getValueCoded());
                }

                if (obx.getConcept().getConceptId().equals( cProcedure.getConceptId())) {
                    listConceptProcedureOfIpdEncounter.add(obx.getValueCoded());
                }
            }
        }

        List<Concept> listConceptDiagnosis = new ArrayList<Concept>();

        if(selectedDiagnosisList!=null){
            for (Integer cId : selectedDiagnosisList) {
                Concept cons = conceptService.getConcept(cId);
                listConceptDiagnosis.add(cons);
                //if (!listConceptDianosisOfIpdEncounter.contains(cons)) {
                Obs obsDiagnosis = new Obs();
                //obsDiagnosis.setObsGroup(obsGroup);
                obsDiagnosis.setConcept(cDiagnosis);
                obsDiagnosis.setValueCoded(cons);
                obsDiagnosis.setCreator(user);
                obsDiagnosis.setObsDatetime(date);
                obsDiagnosis.setLocation(location);
                obsDiagnosis.setDateCreated(date);
                obsDiagnosis.setPatient(ipdEncounter.getPatient());
                obsDiagnosis.setEncounter(ipdEncounter);
                obsDiagnosis = Context.getObsService().saveObs(obsDiagnosis, "update obs diagnosis if need");
                obses.add(obsDiagnosis);
                //}
            }
        }
        List<Concept> listConceptProcedure = new ArrayList<Concept>();
        if (!ArrayUtils.isEmpty(selectedDischargeProcedureList)) {

            if (cProcedure == null) {
                try {
                    throw new Exception("Post for procedure concept null");
                }
                catch (Exception e) {
                    // TODO Auto-generated catch block
                    e.printStackTrace();
                }
            }
            for (Integer pId : selectedDischargeProcedureList) {
                Concept cons = conceptService.getConcept(pId);
                listConceptProcedure.add(cons);
                //if (!listConceptProcedureOfIpdEncounter.contains(cons)) {
                Obs obsProcedure = new Obs();
                //obsDiagnosis.setObsGroup(obsGroup);
                obsProcedure.setConcept(cProcedure);
                obsProcedure.setValueCoded(conceptService.getConcept(pId));
                obsProcedure.setCreator(user);
                obsProcedure.setObsDatetime(date);
                obsProcedure.setLocation(location);
                obsProcedure.setPatient(ipdEncounter.getPatient());
                obsProcedure.setDateCreated(date);
                obsProcedure.setEncounter(ipdEncounter);
                obsProcedure = Context.getObsService().saveObs(obsProcedure, "update obs diagnosis if need");
                //ipdEncounter.addObs(obsProcedure);
                obses.add(obsProcedure);
                //}
            }

        }
        ipdEncounter.setObs(obses);

        Context.getEncounterService().saveEncounter(ipdEncounter);


        IpdPatientAdmittedLog ipdPatientAdmittedLog=ipdService.discharge(dischargeAdmittedID, dischargeOutcomes, otherDischargeInstructions );
        OpdPatientQueueLog opdPatientQueueLog=ipdPatientAdmittedLog.getPatientAdmissionLog().getOpdLog();
        opdPatientQueueLog.setVisitOutCome("DISCHARGE ON REQUEST");
        queueService.saveOpdPatientQueueLog(opdPatientQueueLog);
        Encounter encounter=ipdPatientAdmittedLog.getPatientAdmissionLog().getIpdEncounter();
        BillingService billingService = (BillingService) Context.getService(BillingService.class);
        PatientServiceBill patientServiceBill=billingService.getPatientServiceBillByEncounter(encounter);
        patientServiceBill.setDischargeStatus(1);
        billingService.savePatientServiceBill(patientServiceBill);

    }
    //method to convert drugs
    public List<Prescription> getPrescriptions(String json){
        ObjectMapper mapper = new ObjectMapper();
        List<Prescription> list = null;        try {
            list = mapper.readValue(json,
                    TypeFactory.defaultInstance().constructCollectionType(List.class,
                            Prescription.class));

        } catch (IOException e) {
            e.printStackTrace();
        }        return  list;
    }

    public void treatment(@RequestParam(value ="patientId", required = false) Integer patientId,
                          @RequestParam(value = "drugOrder", required = false) String drugOrder,
                          @RequestParam(value = "ipdWard", required = false) String ipdWard,
                          @RequestParam(value ="selectedProcedureList[]", required = false) Integer[] selectedProcedureList,
                          @RequestParam(value ="selectedInvestigationList[]", required = false) Integer[] selectedInvestigationList,
                          @RequestParam(value ="otherTreatmentInstructions", required = false) String otherTreatmentInstructions,
                          @RequestParam(value = "physicalExamination", required = false) String physicalExamination)
    {


        List<Prescription> prescriptionList = getPrescriptions(drugOrder);

        /*List<Prescription> list = mapper.readValue(drugOrder, new TypeReference<List<Prescription>>() { });
        Prescription[] array = mapper.readValue(drugOrder, Prescription[].class);*/

        HospitalCoreService hcs = (HospitalCoreService) Context
                .getService(HospitalCoreService.class);
        IpdService ipdService = Context.getService(IpdService.class);
        IpdPatientAdmitted admitted = ipdService.getAdmittedByPatientId(patientId);
        Patient patient = Context.getPatientService().getPatient(patientId);
        BillingService billingService = Context.getService(BillingService.class);
        AdministrationService administrationService = Context.getAdministrationService();
        GlobalProperty procedure = administrationService.getGlobalPropertyObject(PatientDashboardConstants.PROPERTY_POST_FOR_PROCEDURE);
        GlobalProperty investigationn = administrationService.getGlobalPropertyObject(PatientDashboardConstants.PROPERTY_FOR_INVESTIGATION);
        User user = Context.getAuthenticatedUser();
        Date date = new Date();
        PatientDashboardService patientDashboardService = Context.getService(PatientDashboardService.class);
        Concept cOtherInstructions = Context.getConceptService().getConceptByName("OTHER INSTRUCTIONS");

        Concept cPhysicalExamination = Context.getConceptService().getConceptByName("PHYSICAL EXAMINATION");

        Obs obsGroup = null;
        obsGroup = hcs.getObsGroupCurrentDate(patient.getPersonId());
        Encounter encounter = new Encounter();
        encounter = admitted.getPatientAdmissionLog().getIpdEncounter();

        if (admitted != null) {
            if (!ArrayUtils.isEmpty(selectedProcedureList)) {
                Concept cProcedure = Context.getConceptService().getConceptByName(procedure
                        .getPropertyValue());

                for (Integer pId : selectedProcedureList) {
                    Obs oProcedure = new Obs();
                    oProcedure.setObsGroup(obsGroup);
                    oProcedure.setConcept(cProcedure);
                    oProcedure.setValueCoded( Context.getConceptService().getConcept(pId));
                    oProcedure.setCreator(user);
                    oProcedure.setDateCreated(date);
                    oProcedure.setEncounter(encounter);
                    oProcedure.setPerson(patient);
                    encounter.addObs(oProcedure);
                }

            }

            if (!ArrayUtils.isEmpty(selectedInvestigationList)) {
                Concept coninvt =  Context.getConceptService().getConceptByName(investigationn
                        .getPropertyValue());

                for (Integer pId : selectedInvestigationList) {
                    Obs obsInvestigation = new Obs();
                    obsInvestigation.setObsGroup(obsGroup);
                    obsInvestigation.setConcept(coninvt);
                    obsInvestigation.setValueCoded( Context.getConceptService().getConcept(pId));
                    obsInvestigation.setCreator(user);
                    obsInvestigation.setDateCreated(date);
                    obsInvestigation.setEncounter(encounter);
                    obsInvestigation.setPerson(patient);
                    encounter.addObs(obsInvestigation);
                }

            }

            if (StringUtils.isNotBlank(otherTreatmentInstructions)) {

                Obs obs = new Obs();
                obs.setObsGroup(obsGroup);
                obs.setConcept(cOtherInstructions);
                obs.setValueText(otherTreatmentInstructions);
                obs.setCreator(user);
                obs.setDateCreated(date);
                obs.setEncounter(encounter);
                obs.setPerson(patient);
                encounter.addObs(obs);
            }

            if (StringUtils.isNotBlank(physicalExamination)) {

                Obs obs = new Obs();
                obs.setObsGroup(obsGroup);
                obs.setConcept(cPhysicalExamination);
                obs.setValueText(physicalExamination);
                obs.setCreator(user);
                obs.setDateCreated(date);
                obs.setEncounter(encounter);
                obs.setPerson(patient);
                encounter.addObs(obs);
            }


        }

        IndoorPatientServiceBill bill = new IndoorPatientServiceBill();

        bill.setCreatedDate(new Date());
        bill.setPatient(patient);
        bill.setCreator(Context.getAuthenticatedUser());

        IndoorPatientServiceBillItem item;
        BillableService service;
        BigDecimal amount = new BigDecimal(0);

        Integer[] al1 = selectedProcedureList;
        Integer[] al2 = selectedInvestigationList;
        Integer[] merge = null;
        if (al1 != null && al2 != null) {
            merge = new Integer[al1.length + al2.length];
            int j = 0, k = 0, l = 0;
            int max = Math.max(al1.length, al2.length);
            for (int i = 0; i < max; i++) {
                if (j < al1.length)
                    merge[l++] = al1[j++];
                if (k < al2.length)
                    merge[l++] = al2[k++];
            }
        } else if (al1 != null) {
            merge = selectedProcedureList;
        } else if (al2 != null) {
            merge = selectedInvestigationList;
        }

        boolean serviceAvailable = false;
        if (merge != null) {
            for (Integer iId : merge) {
                Concept c = Context.getConceptService().getConcept(iId);
                service = billingService.getServiceByConceptId(c
                        .getConceptId());
                if(service!=null){
                    serviceAvailable = true;
                    amount = service.getPrice();
                    item = new IndoorPatientServiceBillItem();
                    item.setCreatedDate(new Date());
                    item.setName(service.getName());
                    item.setIndoorPatientServiceBill(bill);
                    item.setQuantity(1);
                    item.setService(service);
                    item.setUnitPrice(service.getPrice());
                    item.setAmount(amount);
                    item.setActualAmount(amount);
                    item.setOrderType("SERVICE");
                    bill.addBillItem(item);
                }
            }
            bill.setAmount(amount);
            bill.setActualAmount(amount);
            bill.setEncounter(admitted.getPatientAdmissionLog()
                    .getIpdEncounter());
            if(serviceAvailable ==true){
                bill = billingService.saveIndoorPatientServiceBill(bill);
            }

            IndoorPatientServiceBill indoorPatientServiceBill = billingService
                    .getIndoorPatientServiceBillById(bill
                            .getIndoorPatientServiceBillId());
            if (indoorPatientServiceBill != null) {
                billingService
                        .saveBillEncounterAndOrderForIndoorPatient(indoorPatientServiceBill);
            }
        }

        if (!ArrayUtils.isEmpty(selectedProcedureList)) {
        Concept conpro = Context.getConceptService().getConceptByName(procedure
                .getPropertyValue());

        Concept concept = Context.getConceptService().getConcept(
                "MINOR OPERATION");
        Collection<ConceptAnswer> allMinorOTProcedures = null;
        List<Integer> id = new ArrayList<Integer>();
        if (concept != null) {
            allMinorOTProcedures = concept.getAnswers();
            for (ConceptAnswer c : allMinorOTProcedures) {
                id.add(c.getAnswerConcept().getId());
            }
        }

        Concept concept2 = Context.getConceptService().getConcept(
                "MAJOR OPERATION");
        Collection<ConceptAnswer> allMajorOTProcedures = null;
        List<Integer> id2 = new ArrayList<Integer>();
        if (concept2 != null) {
            allMajorOTProcedures = concept2.getAnswers();
            for (ConceptAnswer c : allMajorOTProcedures) {
                id2.add(c.getAnswerConcept().getId());
            }
        }

        int conId;
        for (Integer pId : selectedProcedureList) {
            BillableService billableService = billingService
                    .getServiceByConceptId(pId);
            OpdTestOrder opdTestOrder = new OpdTestOrder();
            opdTestOrder.setPatient(patient);
            opdTestOrder.setEncounter(admitted.getPatientAdmissionLog().getIpdEncounter());
            opdTestOrder.setConcept(conpro);
            opdTestOrder.setTypeConcept(DepartmentConcept.TYPES[1]);
            opdTestOrder.setValueCoded(Context.getConceptService().getConcept(pId));
            opdTestOrder.setCreator(user);
            opdTestOrder.setCreatedOn(date);
            opdTestOrder.setBillingStatus(1);
            opdTestOrder.setBillableService(billableService);

            conId = Context.getConceptService().getConcept(pId).getId();
            if (id.contains(conId)) {
                SimpleDateFormat sdf = new SimpleDateFormat(
                        "dd/MM/yyyy");
            }

            if (id2.contains(conId)) {
                SimpleDateFormat sdf = new SimpleDateFormat(
                        "dd/MM/yyyy");
            }
            opdTestOrder.setIndoorStatus(1);
            opdTestOrder.setFromDept(Context.getConceptService().getConcept(Integer.parseInt(ipdWard)).getName().toString());
            patientDashboardService.saveOrUpdateOpdOrder(opdTestOrder);
        }

    }
        if (!ArrayUtils.isEmpty(selectedInvestigationList)) {
            Concept coninvt = Context.getConceptService()
                    .getConceptByName(investigationn.getPropertyValue());


            for (Integer iId : selectedInvestigationList) {
                BillableService billableService = billingService
                        .getServiceByConceptId(iId);
                OpdTestOrder opdTestOrder = new OpdTestOrder();
                opdTestOrder.setPatient(patient);
                opdTestOrder.setEncounter(admitted.getPatientAdmissionLog().getIpdEncounter());
                opdTestOrder.setConcept(coninvt);
                opdTestOrder.setTypeConcept(DepartmentConcept.TYPES[2]);
                opdTestOrder.setValueCoded(Context.getConceptService().getConcept(iId));
                opdTestOrder.setCreator(user);
                opdTestOrder.setCreatedOn(date);
                opdTestOrder.setBillingStatus(1);
                opdTestOrder.setBillableService(billableService);
                opdTestOrder.setScheduleDate(date);
                opdTestOrder.setIndoorStatus(1);
                opdTestOrder.setFromDept( Context.getConceptService().getConcept(Integer.parseInt(ipdWard)).getName().toString());
                patientDashboardService.saveOrUpdateOpdOrder(opdTestOrder);
            }
        }

        for(Prescription p: prescriptionList)
        {
            //System.out.println(p.getName());

            InventoryCommonService inventoryCommonService = Context
                    .getService(InventoryCommonService.class);
            InventoryDrug inventoryDrug = inventoryCommonService
                    .getDrugByName(p.getName());
            InventoryDrugFormulation inventoryDrugFormulation = inventoryCommonService
                    .getDrugFormulationById(p.getFormulation());
            Concept freCon = Context.getConceptService().getConcept(p.getFrequency());

            OpdDrugOrder opdDrugOrder = new OpdDrugOrder();
            opdDrugOrder.setPatient(patient);
            opdDrugOrder.setEncounter(encounter);
            opdDrugOrder.setInventoryDrug(inventoryDrug);
            opdDrugOrder
                    .setInventoryDrugFormulation(inventoryDrugFormulation);
            opdDrugOrder.setFrequency(freCon);
            opdDrugOrder.setNoOfDays(p.getDays());
            opdDrugOrder.setComments(p.getComment());
            opdDrugOrder.setCreator(user);
            opdDrugOrder.setCreatedOn(date);
            opdDrugOrder.setReferralWardName(Context.getConceptService().getConcept(Integer.parseInt(ipdWard)).getName().toString());
            patientDashboardService
                    .saveOrUpdateOpdDrugOrder(opdDrugOrder);
        }
    }
}
