<%
	ui.decorateWith("appui", "standardEmrPage", [title: "Patient Details"])
	ui.includeJavascript("uicommons", "datetimepicker/bootstrap-datetimepicker.min.js")
	ui.includeJavascript("patientdashboardapp", "jq.print.js")
	ui.includeJavascript("patientdashboardapp", "jq.slimscroll.js")

	ui.includeCss("ehrconfigs", "referenceapplication.css")

%>

<script>
	var getJSON = function (dataToParse) {
		if (typeof dataToParse === "string") {
			return JSON.parse(dataToParse);
		}
		return dataToParse;
	}



	function setBedNo(bedNum){
		jq('#transferBedNumber').val(bedNum)
		jq('#addDrugDialog').addClass('hidden')
	}

	jq(function() {
		jq("#transferIpdWard").on("change",function () {
			var currentID = jq(this).val();


			jq.getJSON('${ ui.actionLink("ipdapp", "BedStrength", "getBedStrength")  }',{
				wardId: currentID
			})
					.success(function(data) {

						var pasteBed = '';
						jq('#dump-bed').html('');

						for (var key in data) {
							if (data.hasOwnProperty(key)) {
								var val = data[key];

								for(var i in val){
									if(val.hasOwnProperty(i)){
										var j = val[i];

										pasteBed += '<div class="bp-container" onclick="setBedNo('+i+')" data-bednum="'+i+'" data-people="'+j+'"> <span class="bp-span bno">Bed <b>#' + i + '</b></span> <span class="bp-span bpl" >Patients: <b>' + j+'</b></span></div>';
									}
								}

							}
						}


						jq('#dump-bed').html(pasteBed);

					})
					.error(function(xhr, status, err) {
						jq().toastmessage('showErrorToast', "Error:" + err);
					})
		});

		jq("#transferBedNumber").on("click", function(e) {
			jq('#addDrugDialog').removeClass('hidden')
		});
	});

	jq(function() {
		jq("#tabs").tabs();

		jq('.update-vitals').click(function(){
			if (jq('.update-vitals i').attr('class').indexOf('icon-chevron-right') >= 0){
				jq('.update-vitals i').removeClass('icon-chevron-right');
				jq('.update-vitals i').addClass('icon-chevron-down');

				jq('.update-vitals span').text('Cancel Edit');
				jq('.vitals-edit-page').show(200);
			}
			else{
				jq('.update-vitals i').removeClass('icon-chevron-down');
				jq('.update-vitals i').addClass('icon-chevron-right');

				jq('.update-vitals span').text('Update Vitals');
				jq('.vitals-edit-page').hide(300);

				jq('#vitalStatisticsForm')[0].reset();
			}
		});

		var requestType = localStorage.getItem('requestType');
		if(requestType=="discharge"){
			jq().toastmessage('showSuccessToast', "Patient discharge request sent!");
		}
		else if(requestType=="abscond") {
			jq().toastmessage('showSuccessToast', "Abscond Status appended on the Patient!");
		}
		localStorage.removeItem('requestType');

		jq("#transferButton").click(function(event){
			var transferForm = jq("#transferForm");
			var transferFormData = {
				'admittedId': jq('#transferAdmittedID').val(),
				'toWard': jq('#transferIpdWard').val(),
				'doctor': jq('#transferDoctor').val(),
				'bedNumber': jq('#transferBedNumber').val(),
				'comments': jq('#transferComment').val(),
			};

			if (transferFormData.toWard == ""){
				jq().toastmessage('showErrorToast', "Please specify Destination Ward");
				return false;
			}

			if (transferFormData.bedNumber == ""){
				jq().toastmessage('showErrorToast', "Please specify Destination Bed Number");
				return false;
			}

			if (transferFormData.bedNumber == ""){
				jq().toastmessage('showErrorToast', "Please specify Destination Bed Number");
				return false;
			}

			transferForm.submit(
					jq.getJSON('${ ui.actionLink("ipdapp", "PatientInfo", "transferPatient") }',transferFormData)
							.success(function(data) {
								jq().toastmessage('showSuccessToast', "Patient has been successfully transferred");
								window.location.href = "patientsAdmission.page?ipdWard=${patientInformation.admittedWard}";

							})
							.error(function(xhr, status, err) {
								jq().toastmessage('showErrorToast', "Error:" + err);
							})
			);

		});

		jq("#vitalStatisticsButton").click(function(event){
			var vitalStatisticsForm = jq("#vitalStatisticsForm");
			var vitalStatisticsFormData = {
				'admittedId': jq('#vitalStatisticsAdmittedID').val(),
				'patientId': jq('#vitalStatisticsPatientID').val(),
				'systolicBloodPressure':jq('#vitalStatisticsSystolicBloodPressure').val(),
				'diastolicBloodPressure': jq('#vitalStatisticsDiastolicBloodPressure').val(),
				'pulseRate': jq('#vitalStatisticsPulseRate').val(),
				'temperature': jq('#vitalStatisticsTemperature').val(),
				'dietAdvised': jq('#vitalStatisticsDietAdvised').val(),
				'notes': jq('#vitalStatisticsComment').val(),
				'ipdWard': jq('#vitalStatisticsIPDWard').val(),
			};
			vitalStatisticsForm.submit(
					jq.getJSON('${ ui.actionLink("ipdapp", "PatientInfo", "saveVitalStatistics") }',vitalStatisticsFormData)
							.success(function(data) {
								location.reload();
							})
							.error(function(xhr, status, err) {
								jq().toastmessage('showErrorToast', "Error:" + err);
							})
			);
		});


		//dicharge patient send post information
		jq("#dischargeSubmit").click(function(event){
			var dischargeForm = jq("#dischargeForm");

			//fetch the selected discharge diagnoses and store in an array
			var selectedDiag = new Array;

			jq("#selectedDiagnosisList option").each  ( function() {
				selectedDiag.push ( jq(this).val() );
			});

			//get the list of selected procedures and store them in an array
			var selectedDischargeProcedureList = new Array;

			jq("#selectedDischargeProcedureList option").each  ( function() {
				selectedDischargeProcedureList.push ( jq(this).val() );
			});



			var dischargeFormData = {
				'dischargeAdmittedID': jq('#dischargeAdmittedID').val(),
				'patientId': jq('#dischargePatientID').val(),
				'selectedDiagnosisList': selectedDiag,
				'selectedDischargeProcedureList': selectedDischargeProcedureList,
				'dischargeOutcomes': jq('#dischargeOutcomes').val(),
				'otherDischargeInstructions': jq('#otherDischargeInstructions').val(),
			};

			dischargeForm.submit(
					jq.getJSON('${ ui.actionLink("ipdapp", "PatientInfo", "dischargePatient") }',dischargeFormData)
							.success(function(data) {
								jq().toastmessage('showNoticeToast', "Discharge form  submitted");
							})
							.error(function(xhr, status, err) {
								jq().toastmessage('showErrorToast', "Error:" + err);
							})
			);

		});
	});

	//reqeust for discharge
	function requestForDischarge(id, ipdWard, obStatus) {
		var dischargeData = {
			'id': id,
			'ipdWard': ipdWard,
			'obStatus':obStatus
		};

		jq.getJSON('${ ui.actionLink("ipdapp", "patientInfo", "requestForDischarge") }', dischargeData)
				.success(function (data) {
					localStorage.setItem('requestType',"discharge");
					location.reload();
				})
				.error(function (xhr, status, err) {
					jq().toastmessage('showErrorToast', "AJAX error!" + err);
				})
	}
	//Abscond
	function abscond(id, ipdWard, obStatus) {
		var abscondData = {
			'id': id,
			'ipdWard': ipdWard,
			'obStatus':obStatus
		};

		jq.getJSON('${ ui.actionLink("ipdapp", "patientInfo", "requestForDischarge") }', abscondData)
				.success(function (data) {
					localStorage.setItem('requestType',"abscond");
					location.reload();
				})
				.error(function (xhr, status, err) {
					jq().toastmessage('showErrorToast', "AJAX error!" + err);
				})
	}

	function selectTab(tabIdnt){
		jq('#tabs').tabs('select', tabIdnt);
	}

</script>

<style>

#person-detail{
	display: none;
}
.toast-item {
	background-color: #222;
}
.morebuttons{
	display: inline;
	float: left;
	margin-left: 20px;
}
.tableelement{
	width: auto;
	min-width: 10px;
}
.vitalstatisticselements{
	float:left;
	margin-left:10px;
	margin-bottom: 10px;
}
.vitalstatisticselements textarea{
	height: 23px;
	width: 183px;
}
.selecticon{
	float: right;
	vertical-align: middle;
	font-size: x-large;
}
.selectp{
	min-width: 450px;
	border-bottom: solid;
	border-bottom-width: 1px;
	padding-left: 5px;
	margin-top:20px;
}
.selectdiv{
	width: 450px;
	margin-top:10px;
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
#tabs {
	background: #f9f9f9 none repeat scroll 0 0;
	padding: 10px;
}
#tab-container{
	background: #f9f9f9 none repeat scroll 0 0;
	margin-top: 3px;
}
.ui-tabs .ui-tabs-panel {
	background: #fff none repeat scroll 0 0;
	padding-top: 0;
}
.col12{
	display: inline-block;
	float: left;
	width: 50%;
}
.col13{
	display: inline-block;
	float: left;
	width: auto;
}
.col15 {
	display: inline-block;
	float: left;
	max-width: 22%;
	min-width: 22%;
}
.col16 {
	display: inline-block;
	float: left;
	width: 78%;
}
.dashboard .action-section {
	background: white none repeat scroll 0 0;
	border: 1px solid #ddd;
	margin-top: 35px;
}
.dashboard .info-body label {
	display: inline-block;
	font-size: 90%;
	margin-bottom: 6px;
	margin-left: 5px;
	width: 115px;
}
.dashboard .info-body span {
	color: #000;
	font-size: 0.9em;
}
.zero-em{
	font-size: 0em!important;
}
.dashboard .info-header h3 {
	color: #f26522;
}
.daily-vitals label{
	float: left;
}
.daily-vitals span {
	display: block;
	overflow: hidden;
	padding-right:10px;
}
.daily-vitals input,
.daily-vitals select,
.daily-vitals textarea{
	width: 100%;
	resize: none;
}
.ui-widget-content a.right {
	cursor: pointer;
	font-size: 16px;
}
.ui-widget-content a.right:hover,
.ui-widget-content a.right:hover i {
	color: #3399ff;
	text-decoration: none;
}
form input:focus, form select:focus, form textarea:focus, form ul.select:focus, .form input:focus, .form select:focus, .form textarea:focus, .form ul.select:focus{
	outline: 0px none #007fff;
	box-shadow: 0 0 2px 0 #888;
}
.dashboard .action-section a:not(.button) {
	cursor: pointer;
}
#addDrugDialog{
	position: absolute;
	top: 0%;
	z-index: 3000;
	left: 25%;
	width: 60%;
	overflow: auto;
	height: 90%;
	min-height: 550px;
}
.hidden{
	display: none;
}
#dump-bed{
	width: 100%;
	display: grid;
	grid-template-columns: repeat(6, auto);
	gap: 7px;
	padding-bottom: 14px;
}
.bp-container{
	display: flex;
	flex-direction: column;
	align-items: flex-start;
	padding: 2px;
}
.bp-span{
	padding: 3px;
}
.bp-container{
	padding: 3px;
	background-color: firebrick;
	color: white;
	cursor: pointer;
}
.bp-container[data-people="0"]{
	background-color: #34bf6e;
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
			Details
		</li>
	</ul>
</div>

<div class="patient-header new-patient-header">
	<div class="demographics">
		<h1 class="name">
			<span id="surname">${patient.familyName},<em>surname</em></span>
			<span id="othname"> ${patient.middleName?patient.middleName:''}&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;<em>other names</em></span>


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
		<div class="tad">Bed ${patientInformation.bed}</div>
	</div>

	<div class="identifiers">
		<em>&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;Patient ID</em>
		<span>${patient.getPatientIdentifier()}</span>
		<br>

		<div class="catg">
			<i class="icon-tags small" style="font-size: 16px"></i><small>Category:</small> ${patient.getAttribute(14)}
		</div>
	</div>
	<div class="clear"></div>
</div>

<div id="tab-container">
	<div id="tabs">
		<ul>
			<li class="tabs1"><a href="#tabs-1">Patient Details</a></li>
			<li class="tabs2"><a href="#tabs-2">Clinical History</a></li>
			<li class="tabs3"><a href="#tabs-3">Lab Reports</a></li>
			<li class="tabs4"><a href="#tabs-4">Transfer</a></li>
		</ul>

		<div id="tabs-1">
			${ui.includeFragment("ipdapp", "patientInfoDetails")}
		</div>

		<div id="tabs-2">
			${ ui.includeFragment("ipdapp", "visitSummary", [patientId: patient.patientId]) }
		</div>
		<div id="tabs-3">
			${ ui.includeFragment("ipdapp", "investigations", [patientId: patient.patientId]) }
		</div>

		<div id="tabs-4">
			${ui.includeFragment("ipdapp", "patientInfoTransfer")}
		</div>


	</div>
</div>