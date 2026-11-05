# Weak Password Change or Reset Functionalities

- **Category:** OWASP A07:2021 – Identification and Authentication Failures; WSTG-ATHN-09 – Weak Password Change or Reset Functionalities.
- **Location:**
    /profile/me/settings
- **Discovery:**
    In the Benjamin's post on Forum, he gave a hint about resetting passwords. 
- **Steps to Reproduce:** (Step by step, so anyone can follow along)
  1. Reset password of an user using `./exploit.sh`
  2. Go to `http://localhost:4942/profile/me/settings`
  3. Find the flag on his profile.
- **Flag:** FLAG{r3s3t_t0k3n_w4s_just_md5_lol}
- **Cause:** 
  In the url of resetting password, the token was included and this token was simply md5 hashed with email address. Plus, there's no email verification. If anyone knows someone's email address, you can md5-hash it and send a request to reset the user's password. 
- **Remediation:**
  - Generate reset tokens with a cryptographically secure random number generator. Make them single use and short lived.
  - Deliver each token through a verified recovery channel and require it before changing the password.
  - Store only a hash of the token and avoid leaking it through logs or third-party requests from the reset page.
