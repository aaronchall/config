{ # get with wpa_passphrase ESSID <PSK>:
  NETGEAR04.pskRaw = "aa9f4ac2734f56d017001bf59f6e6da6ecc2e67b54fc4769539565b7efdcc3c5";
  "5224".psk = "blah";
  "dd-wrt".psk = "blah";
  "DKLB BKLN".psk = "blah";
  "uwf-argo-air" = {
    hidden = true;
    auth = ''
      key_mgmt=WPA-EAP
      eap=PEAP
      phase2="auth=MSCHAPV2"
      identity="blah42"
      password="blahblahblah"
      '';
  }; 
}
