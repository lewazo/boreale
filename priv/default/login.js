function initLoginForm() {
  const form = document.getElementById("form");

  form.addEventListener("submit", (event) => {
    const formData = new FormData(form);
    const xhr = new XMLHttpRequest();

    formData.append("action", "login");

    encodedData = new URLSearchParams(formData).toString();

    xhr.open("POST", "/", false);
    xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
    xhr.withCredentials = true;

    xhr.onload = (_event) => {
      if (xhr.status == 300) {
        window.location = window.location.href;
      } else {
        alert(xhr.response);
      }
    };

    xhr.send(encodedData);

    event.preventDefault();
  }, false);
}
