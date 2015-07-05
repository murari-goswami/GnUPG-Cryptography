The project will install GnUPG software in a System and the Application will encrypt the files to facilitate end to end file security while sharing them with some third party application through public network.
In order to acheive tha PGP open source software is used. This can be acheived by using the Apache GnUPG cryptography package.
The GNU Privacy Guard (GnuPG) is a complete implementation of the OpenPGP Internet standard as described by RFC4880 (formerly RFC2440). It is used for digital encryption and signing of data and mainly useful for data sharing through unsecure public netwotk and data storage.
This encryption utility is build between HP Alpha and Windows 2010 Server.
The most stable version of Open PGP released for HP Tru 64 is 1.4 1.4.10. 
However the Interfacewith Win 2010 Server and the most stable release is 2.0.
This seems tricky as the two versions of Software in two different OS and no valid case study and proof of implementation. This would be the first of its kind of proof of solution towards the implemantation of the GnuPG encryption software.
The first step would be to generate the keys and use them to encrypt files in all Batch Scripts.
The encryption key software runs with the belo logic.
  1. With two system in hand system A and System B. For sending the encrypted file from system A to B, the outgoing file from       system A needs to be encrypted with public key of sysem B.
  2. Once the file reaches at system B, the system B will capable to decrypt the files with its private keys as originally the      source file weere encrypted with its own public keys.  
  3. Vice versa for the other way of processing. 
  
Here are the complete steps to create the keys and how we have used them in our Batch Jobs.

Steps to Generate keys.

1.  $gpg –gen-key

        gpg (GnuPG) 1.4.10; Copyright (C) 2008 Free Software Foundation, Inc.
        This is free software: you are free to change and redistribute it.
        There is NO WARRANTY, to the extent permitted by law.
      
        gpg: WARNING: using insecure memory!
        gpg: please see http://www.gnupg.org/faq.html for more information
        Please select what kind of key you want:
        (1) RSA and RSA (default)
        (2) DSA and Elgamal
        (3) DSA (sign only)
        (4) RSA (sign only)
        Your selection? 1
        RSA keys may be between 1024 and 4096 bits long.
        What keysize do you want? (2048) 2048
        Requested keysize is 2048 bits
        Please specify how long the key should be valid.
        0 = key does not expire
        <n>  = key expires in n days
        <n>w = key expires in n weeks
        <n>m = key expires in n months
        <n>y = key expires in n years
        Key is valid for? (0) 0

        Key does not expire at all
        
        You need a user ID to identify your key; the software constructs the user ID
        from the Real Name, Comment and Email Address in this form:
            “Heinrich Heine (Der Dichter) <heinrichh@duesseldorf.de>”
        Real name: Tedload
        Email address: tedsupport@o2.com
        Comment: Teds Test Box
        You selected this USER-ID:
            “Tedload (Teds Test Box) <tedsupport@o2.com>”
        Change (N)ame, (C)omment, (E)mail or (O)kay/(Q)uit? O
        You need a Passphrase to protect your secret key.
        We need to generate a lot of random bytes. It is a good idea to perform
        some other action (type on the keyboard, move the mouse, utilize the
        disks) during the prime generation; this gives the random number
        generator a better chance to gain enough entropy.
        ^[^[^[
        Not enough random bytes available.  Please do some other work to give
        the OS a chance to collect more entropy! (Need 300 more bytes)
        ^R
        ..+++++
        ..+++++
        We need to generate a lot of random bytes. It is a good idea to perform
        some other action (type on the keyboard, move the mouse, utilize the
        disks) during the prime generation; this gives the random number
        generator a better chance to gain enough entropy.
        Not enough random bytes available.  Please do some other work to give
        the OS a chance to collect more entropy! (Need 92 more bytes)
        ..+++++
        ……+++++
        gpg: /home/tedload/.gnupg/trustdb.gpg: trustdb created
        gpg: key 0FCF6E5E marked as ultimately trusted
        public and secret key created and signed.
        gpg: checking the trustdb
        gpg: 3 marginal(s) needed, 1 complete(s) needed, PGP trust model
        gpg: depth: 0  valid:   1  signed:   0  trust: 0-, 0q, 0n, 0m, 0f, 1u
        pub   2048R/0FCF6E5E 2013-12-12
              Key fingerprint = A448 34C4 7CBB 1EBE 2F7D  52AB 44E7 919A 0FCF 6E5E
        uid                  Tedload (Teds Test Box) <tedsupport@o2.com>
        sub   2048R/4403D5FB 2013-12-12


2. Extract the Key out and give it to the Interface.

        $gpg –armor –output pubkey_teds.txt –export ‘<USER_NAME> (<SOME DESCRIPTION>) <xyg@gmail.com>’
        $ ls -ltr | tail -1
        -rw-r–r–   1 tedload  dev            1726 Dec 12 11:21 pubkey_teds.txt


3. Now deliver the Keys to the Interface so that they can import the Keys in their environment. This can be done offline     
   delivery, so that this key should not get in wrong hands.

4. Next Step to import the public keys from the Interface to import the key and encrypt all files for them.
      
        $gpg –import TMpubkey2.key
        gpg: WARNING: using insecure memory!
        gpg: please see http://www.gnupg.org/faq.html for more information
        gpg: key 69975E21: public key “Tescomobile <David.Jukes@Tesco-mobile.com>” imported
        gpg: Total number processed: 1
        gpg:               imported: 1
        $ gpg –list-keys
        gpg: WARNING: using insecure memory!
        gpg: please see http://www.gnupg.org/faq.html for more information
        /home/tedload/.gnupg/pubring.gpg
        pub   1024D/69975E21 2008-06-09
        uid                  Tescomobile <David.Jukes@Tesco-mobile.com>
        sub   1024g/305F2D75 2008-06-09
        $ gpg –edit-key “Tescomobile <David.Jukes@Tesco-mobile.com>” sign
        gpg (GnuPG) 1.4.10; Copyright (C) 2008 Free Software Foundation, Inc.
        This is free software: you are free to change and redistribute it.
        There is NO WARRANTY, to the extent permitted by law.
        gpg: WARNING: using insecure memory!
        gpg: please see http://www.gnupg.org/faq.html for more information
        pub  1024D/69975E21  created: 2008-06-09  expires: never       usage: SC
                             trust: unknown       validity: unknown
        sub  1024g/305F2D75  created: 2008-06-09  expires: never       usage: E
        [ unknown] (1). Tescomobile <David.Jukes@Tesco-mobile.com>
        pub  1024D/69975E21  created: 2008-06-09  expires: never       usage: SC
                             trust: unknown       validity: unknown
        Primary key fingerprint: 3FEA 392C 2923 51B5 AE15  FE44 8FE2 ECDC 6997 5E21
             Tescomobile <David.Jukes@Tesco-mobile.com>
        Are you sure that you want to sign this key with your
        key “tedload (Teds Dev Box) <tedsupport@o2.com>” (474308C7)
        Really sign? (y/N) y
        You need a passphrase to unlock the secret key for
        user: “tedload (Teds Dev Box) <tedsupport@o2.com>”
        2048-bit RSA key, ID 474308C7, created 2013-11-25
        Command> trust
        pub  1024D/69975E21  created: 2008-06-09  expires: never       usage: SC
                             trust: unknown       validity: unknown
        sub  1024g/305F2D75  created: 2008-06-09  expires: never       usage: E
        [ unknown] (1). Tescomobile <David.Jukes@Tesco-mobile.com>
        Please decide how far you trust this user to correctly verify other users’ keys
        (by looking at passports, checking fingerprints from different sources, etc.)
          1 = I don’t know or won’t say
          2 = I do NOT trust
          3 = I trust marginally
          4 = I trust fully
          5 = I trust ultimately
          m = back to the main menu
        Your decision? 4
        pub  1024D/69975E21  created: 2008-06-09  expires: never       usage: SC
                             trust: full          validity: unknown
        sub  1024g/305F2D75  created: 2008-06-09  expires: never       usage: E
        [ unknown] (1). Tescomobile <David.Jukes@Tesco-mobile.com>
        Please note that the shown key validity is not necessarily correct
        unless you restart the program.

Command> quit
Save changes? (y/N) y


$ gpg –encrypt –batch -r “Tescomobile <XYZ@Tesco-mobile.com>” tm_disc_balance_20131127.psv
        gpg: WARNING: using insecure memory!
        gpg: please see http://www.gnupg.org/faq.html for more information
        gpg: checking the trustdb
        gpg: 3 marginal(s) needed, 1 complete(s) needed, PGP trust model
        gpg: depth: 0  valid:  12  signed:   1  trust: 0-, 0q, 0n, 0m, 0f, 12u
        gpg: depth: 1  valid:   1  signed:   0  trust: 0-, 0q, 0n, 0m, 1f, 0u
        gpg: next trustdb check due at 2014-03-28
    
$ ls –ltr
        -rw-r—–   1 tedload  tedliv      7423 Nov 28 15:19 tm_disc_balance_20131127.psv.gpg

This file is ready to share with the exteral interface who can decryp the files with its own provate keys.

