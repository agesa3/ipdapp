<%
	ui.decorateWith("appui", "standardEmrPage", [title: "Patient Treatment"])

	ui.includeCss("ehrconfigs", "jquery.dataTables.min.css")
	ui.includeCss("ehrconfigs", "onepcssgrid.css")
	ui.includeCss("ehrconfigs", "referenceapplication.css")

	ui.includeCss("ehrinventoryapp", "main.css")
	ui.includeCss("ehrconfigs", "custom.css")

	ui.includeJavascript("kenyaui", "pagebus/simple/pagebus.js")
	ui.includeJavascript("kenyaui", "kenyaui-tabs.js")
	ui.includeJavascript("kenyaui", "kenyaui-legacy.js")
	ui.includeJavascript("ehrconfigs", "moment.js")
	ui.includeJavascript("ehrconfigs", "jquery.dataTables.min.js")
	ui.includeJavascript("ehrconfigs", "jq.browser.select.js")

	ui.includeJavascript("ehrconfigs", "knockout-2.2.1.js")
	ui.includeJavascript("ehrconfigs", "emr.js")
	ui.includeJavascript("ehrconfigs", "jquery.simplemodal.1.4.4.min.js")
%>

<script>
	var drugOrder = [];

	var getJSON = function (dataToParse) {
		if (typeof dataToParse === "string") {
			return JSON.parse(dataToParse);
		}
		return dataToParse;
	}

	jq(function(){

		jq("#procedure").autocomplete({
			source: function( request, response ) {
				jq.getJSON('${ ui.actionLink("ipdapp", "PatientInfo", "getProcedures") }',{
					q: request.term
				}).success(function(data) {
					procedureMatches = [];
					for (var i in data) {
						var result = { label: data[i].label, value: data[i].id, schedulable: data[i].schedulable };
						procedureMatches.push(result);
					}
					response(procedureMatches);
				});
			},
			minLength: 3,
			select: function( event, ui ) {
				var selectedProcedure = document.createElement('option');
				selectedProcedure.value = ui.item.value;
				selectedProcedure.text = ui.item.label;
				selectedProcedure.id = ui.item.value;
				var selectedProcedureList = document.getElementById("selectedProcedureList");

				//adds the selected procedures to the div
				var selectedProcedureP = document.createElement("div");
				selectedProcedureP.className = "selectp";

				var selectedProcedureT = document.createTextNode(ui.item.label);
				selectedProcedureP.id = ui.item.value;
				selectedProcedureP.appendChild(selectedProcedureT);

				var btnselectedRemoveIcon = document.createElement("span");
				btnselectedRemoveIcon.className = "icon-remove selecticon";
				btnselectedRemoveIcon.id = "procedureRemoveIcon";

				selectedProcedureP.appendChild(btnselectedRemoveIcon);

				var selectedProcedureDiv = document.getElementById("selected-procedures");

				//check if the item already exist before appending
				var exists = false;
				for (var i = 0; i < selectedProcedureList.length; i++) {
					if(selectedProcedureList.options[i].value==ui.item.value)
					{
						exists = true;
					}
				}

				if(exists == false)
				{
					selectedProcedureList.appendChild(selectedProcedure);
					selectedProcedureDiv.appendChild(selectedProcedureP);
				}

				jq('#task-procedure').show();
				jq('#procedure-set').val('SET');
			},
			open: function() {
			},
			close: function() {
				jq(this).val('');
			}
		});

		jq("#selected-procedures").on("click", "#procedureRemoveIcon",function(){
			var procedureP = jq(this).parent("div");
			var procedureId = procedureP.attr("id");

			jq('#selectedProcedureList').find("#" + procedureId).remove();
			procedureP.remove();

			if (jq('#selectedProcedureList option').size() == 0){
				jq('#task-procedure').hide();
				jq('#procedure-set').val('');
			}
		});

		jq("#investigation").autocomplete({
			source: function( request, response ) {
				jq.getJSON('${ ui.actionLink("ipdapp", "PatientInfo", "getInvestigations") }',
						{
							q: request.term
						}
				).success(function(data) {
					var results = [];
					for (var i in data) {
						var result = { label: data[i].name, value: data[i].id};
						results.push(result);
					}
					response(results);
				});
			},
			minLength: 3,
			select: function( event, ui ) {
				var selectedInvestigation = document.createElement('option');
				selectedInvestigation.value = ui.item.value;
				selectedInvestigation.text = ui.item.label;
				selectedInvestigation.id = ui.item.value;
				var selectedInvestigationList = document.getElementById("selectedInvestigationList");

				//adds the selected procedures to the div
				var selectedInvestigationP = document.createElement("div");
				selectedInvestigationP.className = "selectp";

				var selectedInvestigationT = document.createTextNode(ui.item.label);
				selectedInvestigationP.id = ui.item.value;
				selectedInvestigationP.appendChild(selectedInvestigationT);

				var btnselectedRemoveIcon = document.createElement("span");
				btnselectedRemoveIcon.className = "icon-remove selecticon";
				btnselectedRemoveIcon.id = "investigationRemoveIcon";

				selectedInvestigationP.appendChild(btnselectedRemoveIcon);

				var selectedInvestigationDiv = document.getElementById("selected-investigations");

				//check if the item already exist before appending
				var exists = false;
				for (var i = 0; i < selectedInvestigationList.length; i++) {
					if(selectedInvestigationList.options[i].value==ui.item.value)
					{
						exists = true;
					}
				}

				if(exists == false)
				{
					selectedInvestigationList.appendChild(selectedInvestigation);
					selectedInvestigationDiv.appendChild(selectedInvestigationP);
				}

				jq('#task-investigation').show();
				jq('#investigation-set').val('SET');
			},
			open: function() {
				jq( this ).removeClass( "ui-corner-all" ).addClass( "ui-corner-top" );
			},
			close: function() {
				jq( this ).removeClass( "ui-corner-top" ).addClass( "ui-corner-all" );
				jq(this).val('');
			}
		});

		jq("#selected-investigations").on("click", "#investigationRemoveIcon", function(){
			var investigationP = jq(this).parent("div");
			var investigationId = investigationP.attr("id");

			jq('#selectedInvestigationList').find("#" + investigationId).remove();
			investigationP.remove();

			if (jq('#selectedInvestigationList option').size() == 0){
				jq('#task-investigation').hide();
				jq('#investigation-set').val('');
			}
		});

		jq(".drug-name").on("focus.autocomplete", function () {
			var selectedInput = this;
			jq(this).autocomplete({
				source: function( request, response ) {
					jq.getJSON('${ ui.actionLink("ipdapp", "PatientInfo", "getDrugs") }', {
						q: request.term
					}).success(function(data) {
						var results = [];
						for (var i in data) {
							var result = { label: data[i].name, value: data[i].id};
							results.push(result);
						}
						response(results);
					});
				},
				minLength: 3,
				select: function( event, ui ) {
					event.preventDefault();
					jq(selectedInput).val(ui.item.label);
				},
				change: function (event, ui) {
					event.preventDefault();
					jq(selectedInput).val(ui.item.label);

					jq.getJSON('${ ui.actionLink("ipdapp", "PatientInfo", "getFormulationByDrugName") }', {
						"drugName": ui.item.label
					}).success(function(data) {
						var formulations = jq.map(data, function (formulation) {
							jq('#formulationsSelect').append(jq('<option>').text(formulation.name + ":" + formulation.dozage).attr('value', formulation.id));
						});
					});
				},
				open: function() {
					//jq( this ).removeClass( "ui-corner-all" ).addClass( "ui-corner-top" );
				},
				close: function() {
					//jq( this ).removeClass( "ui-corner-top" ).addClass( "ui-corner-all" );
				}
			});
		});

		var adddrugdialog = emr.setupConfirmationDialog({
			selector: '#addDrugDialog',
			actions: {
				confirm: function() {
					if (jq('#drugName').val() == ''){
						jq().toastmessage('showErrorToast', "Kindly ensure that the drug name has been Entered Correctly");
						return false;
					}

					if (jq('#formulationsSelect').val() == 'Select Formulation'){
						jq().toastmessage('showErrorToast', "Kindly ensure that the drug Formulation has been selected Correctly");
						return false;
					}

					if (jq('#drugFrequency').val() == 'Select Frequency'){
						jq().toastmessage('showErrorToast', "Kindly ensure that the drug Frequency has been selected Correctly");
						return false;
					}

					if (!jq.isNumeric(jq('#drugDays').val())){
						jq().toastmessage('showErrorToast', "Kindly ensure that the number of Days has been filled correctly");
						return false;
					}

					var tbody = jq('#drugsTable').children('tbody');
					var table = tbody.length ? tbody : jq('#drugsTable');
					table.append('<tr><td>'+jq("#drugName").val()+'</td><td>'+jq("#formulationsSelect option:selected").text()+'</td><td>'+jq("#drugFrequency option:selected").text()+'</td><td>'+jq("#drugDays").val()+'</td><td>'+jq("#drugComment").val()+'</td></tr>');
					drugOrder.push(
							{
								name: jq("#drugName").val(),
								formulation: jq("#formulationsSelect").val(),
								frequency: jq("#drugFrequency").val(),
								days: jq("#drugDays").val(),
								comment: jq("#drugComment").val()
							}
					);
					jq('#prescription-set').val('SET');
					adddrugdialog.close();
				},
				cancel: function() {
					adddrugdialog.close();
				}
			}
		});

		jq("#addDrugsButton").on("click", function(e){
			adddrugdialog.show();
		});

		jq("#treatmentSubmit").click(function(event){
			jq().toastmessage({
				sticky: true
			});
			var savingMessage = jq().toastmessage('showSuccessToast', 'Please wait as Information is being Saved...');

			var selectedProc = new Array;
			jq("#selectedProcedureList option").each  ( function() {
				selectedProc.push ( jq(this).val() );
			});

			//fetch the selected discharge diagnoses and store in an array
			var selectedInv = new Array;
			jq("#selectedInvestigationList option").each  ( function() {
				selectedInv.push ( jq(this).val() );
			});

			drugOrder = JSON.stringify(drugOrder);

			var treatmentFormData = {
				'patientId': jq('#treatmentPatientID').val(),
				'selectedInvestigationList': selectedInv,
				'selectedProcedureList': selectedProc,
				'drugOrder':drugOrder,
				'ipdWard': jq('#treatmentIPDWard').val(),
				'otherTreatmentInstructions': jq('#otherTreatmentInstructions').val(),
				'physicalExamination' : jq('#physicalExamination').val()
			};

			jq("#treatmentForm").submit(
					jq.getJSON('${ ui.actionLink("ipdapp", "PatientInfo", "treatment") }',treatmentFormData)
							.success(function(data) {
								jq().toastmessage('removeToast', savingMessage);
								jq().toastmessage('showSuccessToast', "Patient Treatment has been updated Successfully");
							})
							.error(function(xhr, status, err) {
								jq().toastmessage('removeToast', savingMessage);
								jq().toastmessage('showErrorToast', "Error:" + err);
							})
			);
		});

	});
</script>

<style>
.toast-item {
	background-color: #222;
}
#breadcrumbs a, #breadcrumbs a:link, #breadcrumbs a:visited {
	text-decoration: none;
}
.name {
	color: #f26522;
}
.new-patient-header .demographics .gender-age {
	font-size: 14px;
	margin-left: -55px;
	margin-top: 12px;
}
.new-patient-header .demographics .gender-age span {
	border-bottom: 1px none #ddd;
}
.new-patient-header .identifiers {
	margin-top: 5px;
}
.tag {
	padding: 2px 10px;
}
.tad {
	background: #666 none repeat scroll 0 0;
	border-radius: 1px;
	color: white;
	display: inline;
	font-size: 0.8em;
	padding: 2px 10px;
}
.status-container {
	padding: 5px 10px 5px 5px;
}
.catg {
	color: #363463;
	margin: 25px 10px 0 0;
}
form input:focus, form select:focus, form textarea:focus, form ul.select:focus, .form input:focus, .form select:focus, .form textarea:focus, .form ul.select:focus,
.simple-form-ui section fieldset select:focus, .simple-form-ui section fieldset input:focus, .simple-form-ui section #confirmationQuestion select:focus, .simple-form-ui section #confirmationQuestion input:focus,
.simple-form-ui #confirmation fieldset select:focus, .simple-form-ui #confirmation fieldset input:focus, .simple-form-ui #confirmation #confirmationQuestion select:focus,
.simple-form-ui #confirmation #confirmationQuestion input:focus, .simple-form-ui form section fieldset select:focus, .simple-form-ui form section fieldset input:focus,
.simple-form-ui form section #confirmationQuestion select:focus, .simple-form-ui form section #confirmationQuestion input:focus, .simple-form-ui form #confirmation fieldset select:focus,
.simple-form-ui form #confirmation fieldset input:focus, .simple-form-ui form #confirmation #confirmationQuestion select:focus, .simple-form-ui form #confirmation #confirmationQuestion input:focus {
	outline: 0px none #007fff;
	box-shadow: 0 0 0 0 #888;
}
#formBreadcrumb{
	background: #fff;
}
#treatmentForm{
	background: #f9f9f9 none repeat scroll 0 0;
	margin-top: 3px;
	display: flex;
	flex-direction: column;
	justify-content: space-around;
	align-items: center;
}
#charges-info{
	display: flex;
	flex-direction: column;
	max-width: 1024px;
	width: 100%;
}
#confirmation {
	min-height: 250px;
	width: 100%;
	max-width: 1024px;
}
.tasks {
	background: white none repeat scroll 0 0;
	border: 1px solid #cdd3d7;
	border-radius: 4px;
	box-shadow: 0 1px 2px rgba(0, 0, 0, 0.05);
	color: #404040;
	font: 14px/20px "Lucida Grande",Verdana,sans-serif;
	margin: 10px 0 0 4px;
	width: 98.6%;
}
.tasks-header {
	background: #f0f1f2 linear-gradient(to bottom, #f5f7fd, #e6eaec) repeat scroll 0 0;
	border-bottom: 1px solid #d1d1d1;
	border-radius: 3px 3px 0 0;
	box-shadow: 0 1px rgba(255, 255, 255, 0.5) inset, 0 1px rgba(0, 0, 0, 0.03);
	color: #f26522;
	line-height: 24px;
	padding: 7px 15px;
	position: relative;
	text-shadow: 0 1px rgba(255, 255, 255, 0.7);
}
.tasks-title {
	color: inherit;
	font-size: 14px;
	font-weight: bold;
	line-height: inherit;
}
.tasks-lists {
	color: transparent;
	font: 0px/0 serif;
	height: 3px;
	margin-top: -11px;
	padding: 10px 4px;
	position: absolute;
	right: 10px;
	text-shadow: none;
	top: 50%;
	width: 19px;
}
.tasks-lists::before {
	background: #8c959d none repeat scroll 0 0;
	border-radius: 1px;
	box-shadow: 0 6px #8c959d, 0 -6px #8c959d;
	content: "";
	display: block;
	height: 3px;
}
.tasks-list {
	font: 13px/20px "Lucida Grande",Verdana,sans-serif;
}
.tasks-list-item {
	-moz-user-select: none;
	border-bottom: 1px solid #aaa;
	cursor: pointer;
	display: inline-block;
	line-height: 24px;
	margin-right: 20px;
	padding: 5px;
	width: 150px;
}
.tasks-list-cb {
	display: none;
}
.tasks-list-mark {
	border: 2px solid #c4cbd2;
	border-radius: 12px;
	display: inline-block;
	height: 20px;
	margin-right: 0;
	position: relative;
	vertical-align: top;
	width: 20px;
}
.tasks-list-mark::before {
	-moz-border-bottom-colors: none;
	-moz-border-left-colors: none;
	-moz-border-right-colors: none;
	-moz-border-top-colors: none;
	border-color: #39ca74;
	border-image: none;
	border-style: solid;
	border-width: 0 0 4px 4px;
	content: "";
	display: none;
	height: 4px;
	left: 50%;
	margin: -5px 0 0 -6px;
	position: absolute;
	top: 50%;
	transform: rotate(-45deg);
	width: 8px;
}
.tasks-list-cb:checked ~ .tasks-list-mark {
	border-color: #39ca74;
}
.tasks-list-cb:checked ~ .tasks-list-mark::before {
	display: block;
}
.tasks-list-desc {
	color: #555;
	font-weight: bold;
}
.tasks-list-cb:checked ~ .tasks-list-desc {
	color: #34bf6e;
}
.tasks-list input[type="radio"] {
	left: -9999px !important;
	position: absolute !important;
	top: -9999px !important;
}
.selectp{
	border-bottom: 1px solid darkgrey;
	margin: 7px 10px;
	padding-bottom: 3px;
	padding-left: 5px;
}
#investigationRemoveIcon,
#procedureRemoveIcon {
	float: right;
	color: #f00;
	cursor: pointer;
	margin: 2px 5px 0 0;
}
fieldset input[type="text"],
fieldset select {
	height: 45px
}
.title-label {
	color: #f26522;
	cursor: pointer;
	font-family: "OpenSansBold",Arial,sans-serif;
	font-size: 1.3em;
	padding-left: 5px;
}
.dialog-content ul li span{
	display: inline-block;
	width: 130px;
}
.dialog-content ul li input{
	width: 255px;
	padding: 5px 10px;
}
.dialog textarea {
	width: 255px;
}
.dialog select {
	display: inline-block;
	width: 255px;
}
.dialog select option {
	font-size: 1em;
}
.dialog .dialog-content li {
	margin-bottom: 3px;
}
.dialog select {
	margin: 0;
	padding: 5px;
}
#modal-overlay {
	background: #000 none repeat scroll 0 0;
	opacity: 0.4 !important;
}
#summaryTable tr:nth-child(2n), #summaryTable tr:nth-child(2n+1) {
	background: rgba(0, 0, 0, 0) none repeat scroll 0 0;
}
#summaryTable {
	margin: -5px 0 -6px;
}
#summaryTable tr, #summaryTable th, #summaryTable td {
	-moz-border-bottom-colors: none;
	-moz-border-left-colors: none;
	-moz-border-right-colors: none;
	-moz-border-top-colors: none;
	border-color: #eee;
	border-image: none;
	border-style: none none solid;
	border-width: 1px;
}
#summaryTable td:first-child {
	vertical-align: top;
	width: 180px;
}
</style>

<div class="example">
	<ul id="breadcrumbs">
		<li>
			<a href="${ui.pageLink('referenceapplication','home')}">
				<i class="icon-home small"></i></a>
		</li>

		<li>
			<i class="icon-chevron-right link"></i>
			<a href="chooseIpdWard.page">IPD Wards</a>
		</li>

		<li>
			<i class="icon-chevron-right link"></i>
			<a href="patientsAdmission.page?ipdWard=${patientInformation.admittedWard}">${patientInformation.admittedWard.name}</a>
		</li>

		<li>
			<i class="icon-chevron-right link"></i>
			<a href="patientInfo.page?search=${patient.patientIdentifier}">${patient.familyName} ${patient.givenName}'s Info</a>
		</li>

		<li>
			<i class="icon-chevron-right link"></i>
			Treatment
		</li>
	</ul>
</div>

<div class="patient-header new-patient-header">
	<div class="demographics">
		<h1 class="name">
			<span id="surname">${patient.familyName},<em>surname</em></span>
			<span id="othname">${patient.givenName} ${patient.middleName?patient.middleName:''}&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;<em>other names</em></span>

			<span class="gender-age">
				<span>
					<% if (patient.gender == "F") { %>
					Female
					<% } else { %>
					Male
					<% } %>
				</span>
				<span id="agename">${patient.age} years (${ui.formatDatePretty(patient.birthdate)}) </span>

			</span>
		</h1>

		<br/>
		<div id="stacont" class="status-container">
			<span class="status active"></span>
			Visit Status
		</div>
		<div class="tag">Admitted</div>
		<div class="tad">Bed 00${patientInformation.bed}</div>
	</div>

	<div class="identifiers">
		<em>&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;Patient ID</em>
		<span>${patient.patientIdentifier}</span>
		<br>

		<div class="catg">
			<i class="icon-tags small" style="font-size: 16px"></i><small>Category:</small> ${patient.getAttribute(14)}
		</div>
	</div>
	<div class="clear"></div>
</div>

<form class="zsimple-form-ui" id="treatmentForm" method="post">
	<section id="charges-info">
		<span class="title">Treatment</span>

		<fieldset>
			<legend>Procedure</legend>
			<input type="text" style="width:98.6%; margin-left:5px;" id="procedure" name="procedure" placeholder="Enter Procedure" />

			<p style="display: none">
				<input type="hidden" id="procedure-set" name="procedure-set" />
			</p>

			<div class="tasks" id="task-procedure" style="display: none;">
				<header class="tasks-header">
					<span id="title-symptom" class="tasks-title">PROCEDURES APPLIED</span>
					<a class="tasks-lists"></a>
				</header>

				<div class="symptoms-qualifiers" data-bind="foreach: signs">
					<select style="display: none" id="selectedProcedureList"></select>
					<div class="symptom-container selectdiv" id="selected-procedures">

					</div>
				</div>
			</div>
		</fieldset>

		<fieldset>
			<legend>Physical Examination</legend>
			<label class="label title-label" style="width: auto; padding-left: 5px;">
				PHYSICAL EXAMINATION
				<span class="important"></span>
			</label>

			<p>
				<textarea id="physicalExamination" name="PhysicalExamination" placeholder="Physical Examination" style="height: 129px; width: 100%; resize: none;"></textarea>
			</p>

		</fieldset>

		<fieldset>
			<legend>Investigation</legend>
			<input type="text" style="width:98.6%; margin-left:5px;" id="investigation" name="investigation" placeholder="Enter Investigations" />

			<p style="display: none">
				<input type="hidden" id="investigation-set" name="investigation-set" />
			</p>

			<div class="tasks" id="task-investigation" style="display: none;">
				<header class="tasks-header">
					<span id="title-symptom" class="tasks-title">INVESTIGATIONS</span>
					<a class="tasks-lists"></a>
				</header>

				<div class="symptoms-qualifiers" data-bind="foreach: signs">
					<select style="display: none" id="selectedInvestigationList"></select>
					<div class="symptom-container selectdiv" id="selected-investigations">

					</div>
				</div>
			</div>
		</fieldset>

		<fieldset>
			<legend>Prescription</legend>
			<label class="label title-label" style="width: auto; padding-left: 5px;">
				PRESCRIBE DRUGS
				<span class="important"></span>
			</label>

			<p style="display: none">
				<input type="hidden" style="width: 450px" id="prescription-set" name="prescription-set"/>
			</p>

			<table id="drugsTable">
				<thead>
				<th style="width: auto;">Drug Name</th>
				<th>Formulation</th>
				<th>Frequency</th>
				<th>Number of Days</th>
				<th>Comment</th>
				</thead>
				<tbody>
				</tbody>
			</table>
			<input type="button" value="Add" class="button confirm" name="addDrugsButton" id="addDrugsButton">
		</fieldset>

		<fieldset>
			<legend>Other Instructions</legend>
			<label class="label title-label" style="width: auto; padding-left: 5px;">
				OTHER INSTRUCTIONS
				<span class="important"></span>
			</label>

			<p>
				<textarea id="otherTreatmentInstructions" name="otherTreatmentInstructions" placeholder="Enter Other Instructions" style="height: 129px; width: 100%; resize: none;"></textarea>
				<input value="${patientInformation.admittedWard.id}" name="treatmentIPDWard" id="treatmentIPDWard" type="hidden">
				<input name="treatmentPatientID" id="treatmentPatientID" value="${patient.patientId}" type="hidden">
			</p>
		</fieldset>
	</section>

	<div id="confirmation" style="min-height: 250px;">
		<span id="confirmation_label" class="title">Confirmation</span>

		<div id="confirmationQuestion" class="focused" style="margin-top:0px">
			<p style="display: none">
				<button class="button submit confirm" style="display: none;"></button>
			</p>

			<div class="dashboard">
				<div class="info-section">
					<div class="info-header">
						<i class="icon-list-ul"></i>
						<h3>TREATMENT SUMMARY &amp; CONFIRMATION</h3>
					</div>

					<div class="info-body">
						<table id="summaryTable">
							<tbody>
							<tr>
								<td><span class="status active"></span>Procedure</td>
								<td>N/A</td>
							</tr>

							<tr>
								<td><span class="status active"></span>Physical Examination</td>
								<td>N/A</td>
							</tr>

							<tr>
								<td><span class="status active"></span>Investigations</td>
								<td>N/A</td>
							</tr>

							<tr>
								<td><span class="status active"></span>Prescriptions</td>
								<td>N/A</td>
							</tr>

							<tr>
								<td><span class="status active"></span>Instructions</td>
								<td>N/A</td>
							</tr>
							</tbody>
						</table>
					</div>
				</div>
			</div>

			<span value="Submit" class="button submit confirm right" id="treatmentSubmit" style="margin: 5px 10px;">
				<i class="icon-save small"></i>
				Save
			</span>

			<span id="cancelButton" class="button cancel" style="margin: 5px">
				<i class="icon-remove small"></i>
				Cancel
			</span>
		</div>
	</div>
</form>

<div id="addDrugDialog" class="dialog" style="display: none">
	<div class="dialog-header">
		<i class="icon-folder-open"></i>
		<h3>Prescription</h3>
	</div>
	<div class="dialog-content">
		<ul>
			<li>
				<span>Drug</span>
				<input class="drug-name" id="drugName" type="text" >
			</li>
			<li>
				<span style="display: block; margin-top: 9px">Formulation</span>
				<select style="width: 100%;" id="formulationsSelect" >
					<option>Select Formulation</option>
				</select>
			</li>
			<li>
				<span style="display: block; margin-top: 9px">Frequency</span>
				<select style="width: 100%;" id="drugFrequency">
					<option>Select Frequency</option>
					<% if (drugFrequencyList!=null &&drugFrequencyList!=""){ %>
					<% drugFrequencyList.each { dfl -> %>
					<option  value="${dfl.name}.${dfl.conceptId}">
						${dfl.name}
					</option>
					<% } %>
					<% } %>
				</select>
			</li>
			<li>
				<span style="display: block; margin-top: 9px">Number of Days</span>
				<input style="width: 100%;" id="drugDays" type="text"  >
			</li>
			<li>
				<span style="display: block; margin-top: 9px">Comment</span>
				<textarea style="width: 100%;" id="drugComment" ></textarea>
			</li>
		</ul>

		<span class="button confirm right" style="margin-right: 1px"> Confirm </span>
		<span class="button cancel"> Cancel </span>
	</div>
</div>