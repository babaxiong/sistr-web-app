function ShowHideFunction() {
  var x = document.getElementById("emailinputform");

  if (x.style.display === "none") {
    x.style.display = "block";
  } else if (x.style.display === "block") {
    x.style.display = "none";
  }
}