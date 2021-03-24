<div class="col16 dashboard">
	<div class="info-section">
		<div class="info-header">
			<i class="icon-diagnosis"></i>
			<h3>PATIENT DETAILS</h3>
		</div>

		<div class="info-body" style="min-height: 180px;">
			<div class="col13">
				<img src="${ui.resourceLink('ipdapp', 'images/patient-icon.jpg')}" style="border: 1px solid #eee; height: 190px; margin-right: 10px;" />
			</div>
			
			<div class="col13 last">
				<label>
					<i class="status active zero-em"></i>
					Patient :
				</label>
				<span>${patient.familyName}  ${patient.middleName?patient.middleName:''}</span>
				<br/>

				<label>
					<i class="status active zero-em"></i>
					Age :
				</label>
				<span>${patientInformation.age.substring(1, patientInformation.age.size())}</span>
				<br/>

				<label>
					<i class="status active zero-em"></i>
					Admitted On:
				</label>
				<span>${ui.formatDatePretty(patientInformation.admissionDate)}</span>
				<br/>
				
				<label>
					<i class="status active zero-em"></i>
					Ward :
				</label>
				<span>${patientInformation.admittedWard.name}</span>
				<br/>

				<label>
					<i class="status active zero-em"></i>
					Bed :
				</label>
				<span>00${patientInformation.bed}</span>
				<br/>

				<label>
					<i class="status active zero-em"></i>
					Admitted By:
				</label>
				<span>${patientInformation.user.person.names}</span>
			</div>
			<div class="clear"></div>
		</div>
	</div>
</div>


<div class="dashboard col15 last">
	<div class="action-section">
		<ul style="min-height: 200px;">
			<h3>&nbsp; &nbsp;General Actions</h3>
			
			<% if (patientInformation.requestForDischargeStatus != 1 && patientInformation.absconded != 1) { %>
				<li>
					<i class="icon-edit"></i>
					<a onclick='requestForDischarge(${patientInformation.id}, ${patientInformation.admittedWard},0)'>Request Discharge</a>
				</li>
				
				<li>
					<i class="icon-share"></i>
					<a onclick='abscond(${patientInformation.id}, ${patientInformation.admittedWard},1)'>Patient Abscorded</a>
				</li>
			<% } %>
			
			
			<% if (patientInformation.absconded == 1) { %>
				<li>
					<i class="icon-user-times"></i>
					<a href="">Remove Patient</a>
				</li>
			<% } else if (patientInformation.requestForDischargeStatus == 1) {%>
				<li>
					<i class="icon-edit"></i>
					<a href="dischargePatient.page?patientId=${patient.id}">Discharge Patient</a>
				</li>
			<% } %>						

			<li>
				<i class="icon-print"></i>
				<a href="">Print Details</a>
			</li>
			
			<h3 style="margin-top: 15px;">&nbsp; &nbsp;Inpatient Actions</h3>
			<li>
				<i class="icon-user-md"></i>
				<a href="patientTreatment.page?patientId=${patient.id}">Update Treatment</a>
			</li>

		</ul>
	</div>
</div>

<div class="dashboard">
	<div class="info-section" style="width: 99.5%;">
		<div class="info-header">
			<i class="icon-vitals"></i>
			<h3>DAILY VITALS</h3>
			
			<a class="right update-vitals">
				<span>Update Vitals</span>
				<i class="small chevron icon-chevron-right" style="font-size: 0.92em;"></i>
			</a>
		</div>

		<div class="info-body vitals-edit-page" style="display: none;">
		<div>
			<div id="errorAlert" class="alert" style="display: none"><b>Please correct the following errors:</b><hr>
            	<ul id="errorsHere"></ul>
            </div>
        </div>
			<form method="post" id="vitalStatisticsForm" style="margin-bottom: 5px;">
				<div class="simple-form-ui">
					<div class="col12 daily-vitals">
						<label>Blood Pressure (Systolic)</label>
						<span>
							<input id="vitalStatisticsSystolicBloodPressure" name="vitalStatisticsSystolicBloodPressure" placeholder="Blood Pressure" type="number" min="0" max="250" required="required"/>
							<i style="color: red; display:none" id="systolicValid"></i>
						</span>
					</div>
					<div class="col12 daily-vitals">
						<label>Blood Pressure <br>(Diastolic)</label>
						<span>
							<input id="vitalStatisticsDiastolicBloodPressure" name="vitalStatisticsDiastolicBloodPressure" placeholder="Blood Pressure" type="number" min="0" max="150" required="required"/>
							<i style="color: red; display:none" id="diastolicValid"></i>
						</span>
					</div>
					<div class="col12 daily-vitals">
						<label>Temperature</label>
						<span>
							<input id="vitalStatisticsTemperature" name="vitalStatisticsTemperature" placeholder="Temperature(C)"  type="number" min="25" max="43" required="required"/>
							<i style="color: red; display:none" id="tempValid"></i>
						</span>
					</div>
					
					<div class="col12 daily-vitals">
						<label>Pulse Rate</label>
						<span>
							<input id="vitalStatisticsPulseRate" name="vitalStatisticsPulseRate" placeholder="Pulse Rate(/min)" type="number" min="0" max="230" required="required"/>
							<i style="color: red; display:none" id="pulseValid"></i>
						</span>
					
						<label>Diet Advised</label>
						<span>
							<select required name="vitalStatisticsDietAdvised" id="vitalStatisticsDietAdvised" >
								<option value="">Select Diet Advised</option>
								<% if (dietList!=null && dietList!=""){ %>
								<% dietList.each { dl -> %>
								<option  value="${dl.name}">
									${dl.name}
								</option>
								<% } %>
								<% } %>
							</select>
						</span>
					</div>
					
					<div class="col12 daily-vitals" style="width: 100%">
						<div>
							<label>Notes</label>
							<span>
								<textarea name="vitalStatisticsComment" id="vitalStatisticsComment" placeholder="Notes if any"></textarea>
							</span>
						</div>
						
						<div style="margin-top: 10px">
							<input name="vitalStatisticsAdmittedID" id="vitalStatisticsAdmittedID" value="${patientInformation.id}" type="hidden">
							<input value="${patientInformation.admittedWard.id}" name="vitalStatisticsIPDWard" id="vitalStatisticsIPDWard" type="hidden">
							<input name="vitalStatisticsrPatientID" id="vitalStatisticsPatientID" value="${patient.patientId}" type="hidden">
							
							<label></label>
							<a id="vitalStatisticsButton" name="vitalStatisticsButton" class="button confirm">
								<i class="icon-save small"></i>
								Save Vitals
							</a>
						</div>								
					</div>
					
					<div class="clear"></div>
				</div>
			</form>						
			<div class="clear"></div>
		</div>
		
		<table id="vitalSummary" style="margin-top: 5px">
			<thead>
				<tr>
					<th style="width: 5px;">#</th>
					<th>DATE</th>
					<th>B.P(Systolic)</th>
					<th>B.P(Diastolic)</th>
					<th>PULSE RATE</th>
					<th>TEMPERATURE</th>
					<th>DIET</th>
					<th>NOTES</th>
				</tr>
			</thead>
			<tbody>
				<% if (ipdPatientVitalStatistics.size() > 0){ %>
					<% ipdPatientVitalStatistics.eachWithIndex { ipvs , idx-> %>
						<tr>
							<td>${idx+1}</td>
							<td>${ipvs.createdOn}</td>
							<td>${ipvs.systolicBloodPressure}</td>
							<td>${ipvs.diastolicBloodPressure}</td>
							<td>${ipvs.pulseRate}</td>
							<td>${ipvs.temperature}</td>
							<td>${ipvs.dietAdvised}</td>
							<td>${ipvs.note}</td>
						</tr>
					<% } %>
				<% } else { %>
					<tr>
						<td></td>
						<td colspan="6">No Vitals Found</td>
					</tr>
				<% } %>
			</tbody>
		</table>
	</div>
</div>
<div class="clear"></div>