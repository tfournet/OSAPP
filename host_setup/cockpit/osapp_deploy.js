const address = document.getElementById("cybercns_hostname");
const output = document.getElementById("output");
const result = document.getElementById("result");
const button = document.getElementById("config");

function ping_run() {
    //cockpit.spawn(["ping", "-c", "4", address.value])
    cockpit.spawn(["touch","/usr/local/share/testfile"])
        .stream(ping_output)
        .then(ping_success)
        .catch(ping_fail);

    result.innerHTML = "";
    output.innerHTML = "";
}

function ping_success() {
    result.style.color = "green";
    result.innerHTML = "success";
}

function ping_fail() {
    result.style.color = "red";
    result.innerHTML = "fail";
}

function ping_output(data) {
    output.append(document.createTextNode(data));
}

// Connect the button to starting the "ping" process
button.addEventListener("click", ping_run);

// Send a 'init' message.  This tells integration tests that we are ready to go
cockpit.transport.wait(function() { });
