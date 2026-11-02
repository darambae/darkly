# Weak Password Change or Reset Functionalities

- **Category:** OWASP A07:2021 – Identification and Authentication Failures; WSTG-ATHN-09 – Weak Password Change or Reset Functionalities.
- **Location:**
    /profile/me/settings
- **Discovery:** (What clue made you suspect it?)
    In the Benjamin's post on Forum, he gave a hint about resetting passwords. 
- **Steps to Reproduce:** (Step by step, so anyone can follow along)
  1. Go to login page and reset password with 'benjamin@student.42.tech'
  2. Login and go to his profile page. 
  3. Find the flag on his profile.
- **Flag:** FLAG{r3s3t_t0k3n_w4s_just_md5_lol}
- **Cause:** (Why was this possible, from a code/design perspective?)
  In the url of resetting password, the token was included and this token was simply md5 hashed with email address. Plus, there's no email verification. If anyone knows someone's email address, you can md5-hash it and send a request to reset the user's password. 
- **Remediation:**
  - Generate reset tokens with a cryptographically secure random number generator. Make them single use and short lived.
  - Deliver each token through a verified recovery channel and require it before changing the password.
  - Store only a hash of the token and avoid leaking it through logs or third-party requests from the reset page.
