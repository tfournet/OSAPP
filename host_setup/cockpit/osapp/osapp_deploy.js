const custAbbr = document.getElementById("custAbbr");
const custTld = document.getElementById("custTld");
const siteSubnet = document.getElementById("siteSubnet");
const siteName = document.getElementById("siteName");
const extDns1 = document.getElementById("extDns1");
const extDns2 = document.getElementById("extDns2");
const cybercns_hostname = document.getElementById("cybercns_hostname");
const cybercns_siteId = document.getElementById("cybercns_siteId");
const Perch_URL = document.getElementById("Perch_URL");
const OPNSense_URL = document.getElementById("OPNSense_URL");
const OPNSense_SHA256 = document.getElementById("OPNSense_SHA256");
const output = document.getElementById("output");
const result = document.getElementById("result");
const button = document.getElementById("config");

function setup_run() {
    cockpit.spawn(["/usr/local/osapp/begin_from_cockpit.sh", custAbbr.value, custTld.value, siteSubnet.value, siteName.value, extDns1.value, extDns2.value, cybercns_hostname.value, cybercns_siteId.value, Perch_URL.value, OPNSense_URL.value, OPNSense_SHA256.value])
        .stream(setup_output)
        .then(setup_success)
        .catch(setup_fail);

    result.innerHTML = "";
    output.innerHTML = "";
}

function setup_success() {
    result.style.color = "green";
    result.innerHTML = "success";
}

function setup_fail() {
    result.style.color = "red";
    result.innerHTML = "fail";
}

function setup_output(data) {
    output.append(document.createTextNode(data));
}

// Connect the button to starting the "setup" process
button.addEventListener("click", setup_run);

// Send a 'init' message.  This tells integration tests that we are ready to go
cockpit.transport.wait(function() { });
