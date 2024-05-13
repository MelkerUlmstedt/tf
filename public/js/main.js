setTimeout(function(){
    document.querySelector('.notice').style.display = 'none';
},3000);

document.addEventListener("DOMContentLoaded", function() {
    var loginAttempts = {$login_attempts};
    var loginButton = document.getElementById('loginButton');
    var strikesMessage = document.querySelector('.notice');

    if (loginAttempts >= 3 && strikesMessage) {
      loginButton.style.display = 'none'; 
      strikesMessage.style.display = 'block'; 
      setTimeout(function() {
        strikesMessage.style.display = 'none'; 
        loginButton.style.display = 'inline-block';
      }, 5000);
    }
  })