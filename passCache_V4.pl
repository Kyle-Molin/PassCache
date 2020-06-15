#!/usr/bin/perl

#Name: Paul Kenneth Padro & Kyle Molin
#Section B
#Date: Feb 28, 2019
#File: passCache_V4.pl
#Version: V4.0

use strict;
use warnings;
use Tie::Hash::Indexed;

my($input,				#used for main menus
	$date,				#used to save current date
	$option,				#used for sub menus		
	$split,				#used in all encryption subroutines to symbolize the one character being split
	$accNum,				#used to track which account user has input and display the index of that account
	%passHash,			#hash for account information holds application, username, and password
	$passHash,			#scalar of hash
	@content,			#This array holds all unencrypted information from a file
	$content,			#scalar of the array to be used in split
	@content2,			#Holds all unencrypted data for display to the user only
	$content2,			#scalar of the array to be used in split
	$app,					#Holds the application name that the user has input
	$username,			#Holds the username that the user has input
	$password,			#Holds the password the user has input
	@searchContent,	#This array holds all the content that was filtered with the search function
	$searchContent,	#scalar of the array to be used in split 		
	$length,				#Holds the length of either @content or searchContent for error checking user input
	$passCheck,			#Used to store the input of the used and compare it to the saved master password iin the file to "check" if the
	 						#passwords match
	$flag,				#Used as a true or false statement for masterpassword, flag will update to 1 if password is correct
	$uLimit,				#Stores the limited amount of characters for display of username
	$aLimit,				#Stores the limited amount of characters for display of application
	$index,				#Used to initialize loops and for error checks 
	$search,				#Stores user input for the parameter that they want to search
	$empty,				#Used as a junk variable to allow the user to hit enter when they are donw reading the info
	$Encrypt,			#Stores the final encrpted password, username, or application name
	$i, 					#Used to iterate through each value in passHash hash for formatted display
	@char_list,			#Used to store values for password creator
	$range,				#Used to specify the length the user wants there password to be
	$check,				#Used for verification if they want to continue with the edit
	$pin,
	$code,
	$email,
	$subject,
	$from,
	$body);
	

opendir(OPENDIR, "/root/passCache") || system("mkdir /root/passCache"); #Checks if passCache DIR is made if not it creates the DIR with all corresponding files
close OPENDIR;
open(OPEN, "/root/passCache/masterPass.txt") || system("touch /root/passCache/masterPass.txt");
close OPEN;
open(OPEN, "/root/passCache/temp.txt") || system("touch /root/passCache/temp.txt");
close OPEN;
open(OPEN, "/root/passCache/pass.rpt") || system("touch /root/passCache/pass.rpt");
close OPEN;
system("clear");										#Calls &date subroutine and stores the returned value into $date variable for re-use
chomp ($date = &date);

$flag = 0;																	#initialize flag
&readwriteCheck();														#Calls to open masterPass file to store the users inputted password (only
																				#writes to this file if this is the users first time opening the program)
&passDecrypt();
$length = @content2;
chomp(@content2);															#removes \n so it can split content properly

if($length > 0)															#checks to see if program has been opened 
																				#before by using the length of the array
{
	foreach $content2(@content2)										#iterates through @content2 spliting the password from the length 
																				#(Stores a 1 in the file to indicate that the program has already been used)
	{
		($length,$password,$email) = split(/,/, $content2);
	}
	while($flag == 0)														#loops until the user inputs the right password
	{
		print("Please Enter Password: ");
		chomp($passCheck = <STDIN>);
		if($passCheck =~ /$password/g)								#if the users passsword matches the password in the 
																				#file they proceed to the rest of the program
		{
			while($flag == 0)														#loops until the user inputs the right password
			{	
				$pin = &authen();
				$from = 'linuxrootk@gmail.com';
				$subject = "passCache two factor athentication";
				$body = "Your code is $pin";
 		
				open(MAIL, "|/usr/sbin/sendmail -t");
 		
				# Email Header
				print MAIL "To: $email\n";
				print MAIL "From: $from\n";
				print MAIL "Subject: $subject\n\n";
				print MAIL $body;
					
				close MAIL;
				system("clear");
				print("Please Enter 9 digit code from your email: ");
				chomp($code = <STDIN>);
				if($code =~ /$pin/g)								#if the users passsword matches the password in the 
																				#file they proceed to the rest of the program
				{
					$flag = 1;														#flag updates to exit while loop
					&welcomeScreen();
					&mainMenu();
				}
				else																	#else they get an "incorrect password" message and they		
				{																		#prompted to enter again
					print("Incorrect code\n");
					sleep(2);
				}
			}
		}
		else																	#else they get an "incorrect password" message and they		
		{																		#prompted to enter again
			print("Incorrect password\n");
			sleep(2);
			print("Forgot your password?\n");
			print("Enter [n] to try again or enter [y] to send your existing password to your email\n");
			chomp($option = <STDIN>);
			Switch:
			{
				($option =~ /n/i) and do
				{
					system("clear");
				};
				($option =~ /y/i) and do
				{
					$from = 'linuxrootk@gmail.com';
					$subject = "passCache user password";
					$body = "Your password is $password";
 
					open(MAIL, "|/usr/sbin/sendmail -t");
 
					# Email Header
					print MAIL "To: $email\n";
					print MAIL "From: $from\n";
					print MAIL "Subject: $subject\n\n";
					print MAIL $body;
					
					close MAIL;
					print "Email Sent Successfully\n";
					sleep(3);
				};
				{
					print("Error, invalid input\n");
					system("clear");
				};
					
			}
		}
	}
}
else																			#executes this else statement if the program has not been opened before
{
	system("clear");
	print("Hello, Please input your email for two factor authentication\n");
	print("This email will also be used incase you ever forget your password\n");
	chomp($email = <STDIN>);
	print("Please input the master Password for your passCache program\n"); 
	print("Password: ");													#prompts user to enter master password
	chomp($password = <STDIN>);										#user inputs master password
	&passSwitch();
}

sub passSwitch
{
	print("WARNING, you will not be able to change your master password after you click [y].\n");
	print("Are you sure your want this to be password?\n"); 
	print("Enter [y]es to confirm or [n]o to change sign-in info:"); 
																				#gives the user a warning to make sure they want to use this password
	chomp($option = <STDIN>);											#gets user input of either y Y, n N, or it errors
	SWITCH:
	{
		($option =~ /y/i) and do										#if user in equals y (ignores case) it runs this statement
		{	
			$length++; 														#increments length so it is not equal to zero when printed into file
			$password = &encryptEditP();								#calls to encrypt users password then assigns encypted password into
			$email = &encryptEmail();
																			 	#$password variable
			print CHECKPASS ("$length\.$password\.$email");				#prints the length and a period between password. 
																				#period needs to be string literal or it will concatinate.
			&welcomeScreen();												#calls the welcome screen subroutine
			&mainMenu();													#calls the main menu subroutine
			last;																#ends switch
		};
		($option =~ /n/i) and do										#if user in equals n (ignores case) it runs this statement
		{
			system("clear");												#clears the screen for new message to pop up
			print("Hello! Please input the master Password for your PassCache program.\n");  
																				#re-prompts greeting message and input message
			print("Password: ");
			chomp($password = <STDIN>);								#gets user in for new password
			&passSwitch();														#calls it's own subroutine for the warning message to 
																				#verify if they want to use new password
			last;																#ends switch
		};
		{
			print("Error, invalid input");							#if user inputs anything that is not y or n then it prints an error statement
			last;																#ends switch
		};
	}
}


sub welcomeScreen															#Welcome Screen Subroutine				
{
	system ("clear");														#Clear existing screen
	print "
	                                              | $date |
	*----------------------------------------------------------*
	|                         PassCache                        |
	|----------------------------------------------------------|
	|                                                          |
	|        Hello, Welcome to PassCache Password Manager      |
	|                                                          |	
	|            What can I help you with today?               |
	|                                                          |
	|                                                          |
	*----------------------------------------------------------*
	";																			#Print welcome message
	sleep 3;
}

sub mainMenu																#Main Menu Subroutine
{
	system ("clear");														#Clear existing screen
	print "
	| PassCache |                                 | $date |
	*----------------------------------------------------------*
	|                        Main Menu                         |
	|----------------------------------------------------------|
	|                                                          |
	|                   1) Manage Accounts                     |
	|                   2) Search                              |
	|                   3) Quit                                |
	|                                                          |
	|                                                          |
	*----------------------------------------------------------*
	Please Select an Option: ";										#Display Main Menu options and prompt user to enter the following options
	$input = <STDIN>;														

	SWITCH:																	#Enter SWITCH case for Main Menu
	{
		($input =~ 1) and do												#Option 1: Call manageAccounts to enter Manage Accounts Menu
		{
			&manageAccounts();
			last;
		};
		($input =~ 2) and do												#Option 2: Call search to enter Search Menu
		{
			&search();
			last;
		};
		($input =~ 3) and do												#Option 3: Call quit to Quit from program
		{
			&quit();
			last;
		};
		{																		#Error message if $input does not match any case
			print"\n\tError, Invalid option\n";
			sleep 2;
			&mainMenu();
			last;
		};
	}

}

sub manageAccounts														#Manage Accounts Subroutine
{
	system ("clear");														#Clear exisisting screen
	print "
	| PassCache |                                 | $date |
	*----------------------------------------------------------*
	|                    Manage Accounts                       |
	|----------------------------------------------------------|
	|                                                          |
	|                   1) Add Accounts                        |
	|                   2) Remove Accounts                     |
	|                   3) Edit Accounts                       |
	|                   4) Return to Main Menu                 |
	|                                                          |
	*----------------------------------------------------------*
	Please Select an Option: ";										#Display Manage Account Menu options and prompt user		
	$input = <STDIN>;														#Read from STDIN to select an option

	SWITCH:																	#Enter SWITCH case for Manage Accounts Menu
	{
		($input =~ 1) and do												#Option 1: Call manageAdd to Add Accounts
		{
			&manageAdd();
			last;
		};
		($input =~ 2) and do												#Option 2: Call manageRemove to Remove Accounts
		{
			&manageRemove();
			last;
		};
		($input =~ 3) and do												#Option 3: Call manageEdit to Edit Accounts
		{
			&manageEdit();
			last;
		};
		($input =~ 4) and do												#Option 4: Call mainMenu to return to Main Menu
		{
		
			&mainMenu();
			last;
		};
		{
			print"\n\tError, Invalid option\n";						#Display Error message
			sleep 2;
			&manageAccounts();											#Call manageAccounts to return to Manage Accounts Menu 
																				#to re-select an option or to exit
			last;																
		};
	}
}

sub manageAdd																#Add Accounts Subroutine
{
	my($counter,															#$counter used as for loop variable
		$key);
	
	system "clear";	
	&passFile(); 																						#calls to open pass.rpt file to append to
	$accNum = 1;																						#initialize and resets account if re-used
	&manageAddHeader();
	print "\t| How many accounts would you like to add today?:          |\n\t\t"; #Prompt user to select the amount of acct to add
	chomp($index=<STDIN>);
	&dash();																								#call dash (Displays a divider)
	for($counter=0;$counter<$index;$counter++) 												#for loop iterates for specified amount that user chooses
	{
		if($accNum != 1)																				#If user has selected more than 1 acount creation
		{																									# re-print the "Add Accounts" header
			&manageAddHeader();
		}
		%passHash=(); 																					#clearing hash for next iteration
		print "\t| Please enter Website/Application for [Acct #$accNum]:          |\n\t\t";
		chomp($app=<STDIN>); 																		#gets user in for website
		&dash();
		
		print "\t| Please enter Username or Email for [Acct #$accNum]:            |\n\t\t";
		chomp($username=<STDIN>); 																	#gets user in for username or email
		&dash();
		
		$check = "n";
		while($check =~ /n/i)
		{
			print"\t| Enter [1] to use your own password                       |\n\t";
			print"| Enter [2] to have one created for you                    |\n\t\t";
			chomp($option=<STDIN>);                                                   	#gets user in for option
			Switch:
			{
				($option == 1) and do
				{
					print "\t| Please enter Passsword for [Acc#$accNum]:                      |\n\t\t";
					chomp($password=<STDIN>);																	#gets password for account
					print "\t| Are you sure you want to use this password?              |\n\t";
					print "| Enter (Yes [Y] or No [N]):                               |\n\t\t";
					chomp ($check = <STDIN>);
					&dash();
					last;
				};
				($option == 2) and do
				{
					$password = &passCreator();
					print "\t| Your new Password is $password                            |\n\t";
					sleep(3);
					print "| Are you satisfied with this password?                    |\n\t";
					print "| Enter (Yes [Y] or No [N]):                               |\n\t\t";
					chomp ($check = <STDIN>);
					last;
				};
				{	
					system("clear");
					print "\t| Error, Invalid index                                           |\n\t\t";
					sleep(3);
					last;
				};
			}
		}
		$i = 0;
		tie %passHash,'Tie::Hash::Indexed';														#Ties %passHash hash so it will always display as
																											#Application, Username, then Password
		
		%passHash=(Application=>$app,Username=>$username,Pass=>$password);			#declaration of hash
		
		printf("\t| Account #%-48d%s\n", $accNum, "|");										#displays what account you are on
		&dash();																							#call dash (Displays a divider)
		foreach $key(keys %passHash)															
		{																						#foreach used to iterate through the hash and display each pair
			if($i == 0)
			{
				printf("\t| Website/Application: %-36s%s",$passHash{$key}, "|");
			}
			elsif($i == 1)
			{
				printf("\n\t| Username: %-47s%s",$passHash{$key}, "|");
			}
			elsif($i == 2)
			{
				printf("\n\t| Password: %-47s%s\n",$passHash{$key}, "|");
			}
			$i++;
		}	

		&dash();																							#call dash (Displays a divider)
		&addCheck();																					#calls addCheck subroutine
		$accNum++;																						#iterate through account numbers
	}
	$accNum--;																							# -1 from Account numbers 
																											#(For loop iterates an extra time because of index)
	&closePassFile(); 																				#calls to close pass.rpt file
	system "clear"; 																					#clears screen to hide what user inputed
print "
	                                              | $date |
	*----------------------------------------------------------*
	|                         PassCache                        |
	|----------------------------------------------------------|
	|                                                          |
	|         [$accNum] account(s) has been successfully added       |
	|                                                          |
	|              Returning you back to main menu             |
	|                                                          |
	|                                                          |
	*----------------------------------------------------------*
";																											#display the number of accounts successfully added
	sleep 3;
	&mainMenu();																						#and return back to main menu
}

sub addCheck																							#addCheck sub was made to check if the user was happy
																						 	#with what they input, if not they iterate though until they say yes
{
	my($key);

		print"\t| Are you sure you want to add this account?               |\n ";
		print"\t| [Y] for Yes                                              |\n ";
		print"\t| [N] To re-enter account information                      |\n\t\t ";
		chomp($option = <STDIN>);
		
		SWITCH:
		{
			($option =~ /y/i) and do											#if user in equals y (ignores case) execute this statement
			{
				system "clear";											#clears screen for next menu
				&encryptApp();												#calls to encrypt Application name that the user input (prints to file in sub)
				&encryptUser();											#calls to encrypt Username that the user input (prints to file in sub)
				&encryptPass();											#calls to encrypt Password that the user input (prints to file in sub)
				print OUTFILE ("\n");									#prints a \n after the end of line			
				last;
			};
			($option =~ /n/i) and do									#if user in equals n (ignores case) execute this statement
			{
				$check = "n";
				system("clear");											#clears screen for add accounts header
				&manageAddHeader();										# re-print the "Add Accounts" header
				 																			
				print "\t| Please enter Website/Application for [Acct #$accNum]:          |\n\t\t";
				chomp($app=<STDIN>); 																#gets user in for website
				&dash();
		
				print "\t| Please enter Username or Email for [Acct #$accNum]:            |\n\t\t";
				chomp($username=<STDIN>); 															#gets user in for username or email
				&dash();
				
				while($check =~ /n/i)
				{
					print"\t| Enter [1] to use your own password                       |\n\t";
					print"| Enter [2] to have one created for you                    |\n\t\t";
					chomp($option=<STDIN>);                                                   	#gets user in for option
					Switch:
					{
						($option == 1) and do
						{
							print "\t| Please enter Passsword for [Acc#$accNum]:                      |\n\t\t";
							chomp($password=<STDIN>);																	#gets password for account
							print "\t| Are you sure you want to use this password?              |\n\t";
							print "| Enter (Yes [Y] or No [N]):                               |\n\t\t";
							chomp ($check = <STDIN>);
							&dash();
							last;
						};
						($option == 2) and do
						{
							$password = &passCreator();
							print "\t| Your new Password is $password                            |\n\t";
							sleep(3);
							print "| Are you satisfied with this password?                    |\n\t";
							print "| Enter (Yes [Y] or No [N]):                               |\n\t\t";
							chomp ($check = <STDIN>);
							last;
						};
						{	
							system("clear");
							print "\t| Error, Invalid index                                           |\n\t\t";
							sleep(3);
							last;
						};
					}
				}
				$i = 0;
				tie %passHash,'Tie::Hash::Indexed';		#Ties %passHash hash so it will always display as Application, Username, then Password
		
				%passHash=(Application=>$app,Username=>$username,Pass=>$password);	#declaration of hash
				
				printf("\t| Account #%-48d%s\n", $accNum, "|");								#displays what account you are on
				&dash();														#call dash (Displays a divider)
				foreach $key(keys %passHash)							#foreach used to iterate through the hash and display each pair
				{
					if($i == 0)
					{
						printf("\t| Website/Application: %-36s%s",$passHash{$key}, "|");
					}
					elsif($i == 1)
					{
						printf("\n\t| Username: %-47s%s",$passHash{$key}, "|");
					}
					elsif($i == 2)
					{
						printf("\n\t| Password: %-47s%s\n",$passHash{$key}, "|");
					}
					$i++;
				}
				&dash();														#call dash (Displays a divider)
				&addCheck();									#re-calls addCheck sub to make sure the info that user user has input is correct
				last;
			};
			{
				print"Invalid input";						#Display error message if user inputs something either then y or n
				system("clear");
				&addCheck();
				last;
			};
		}
}

sub passCreator
{
	@char_list=('0'..'9', 'A'..'Z', 'a'..'z', '@', '$', '?', '#');

	print "\t| Please input password length                             |\n\t";
	print "| (We recommend at least a length of 8):                   |\n\t\t";
	chomp($range = <STDIN>);
	$check = 0;

	if($range >= 3)							#error check to see if input is greater than 3 if input was not greater then 3
	{												#without this statement the program would hang because it needs a special character
		while($check != 2)					#a letter (anycase) and a number in the password to be displayed
		{					
	   	 $password = ();
	   	 for(1..$range)					#uses user input to set number of iterations
	   	 {
	   	    $password .= $char_list[rand @char_list]; #gets random index from array of characters and concatintes them into $passsword
	   	 }
	
	   	 if($password =~ /\d\w/ && $password =~ /[\@\#\$\?]/) #Checks to see if the password has a letter a digit and a special 
	   	 {																		#character in the password
	   	     $check = 2;													#assigns 2 to be let out of the while loop
	   	 }
		}
		return($password);
	}
	else
	{
		print("Error, Invalid index\n");
		print("Password needs to be a minimum length of 3!\n");
		sleep(2);
		system("clear");
		&passCreator();
	}
}

sub manageRemove												#Remove Accounts Subroutine
{
	my($censor,													#holds the substring for the password (limits number of characters shown)
		$censoredPass,											#holds fully censored password
		$star,													#holds stars for password censor
		$input);
	
	system "clear";											#clears screen for Remove Header
	&readWriteFile();											#opens pass.rpt to read/write
	&decrypt();													#calls decrypt sub to decrypt all info in the pass.rpt file
	&manageRemoveHeader();									#displays Remove Header																  
	print "\n\t| Displaying all accounts (Website|Username|Password):     |\n";
	&dash();
	print "\t| [ #]   Website/App   |    Username     |   Password      |\n";		#displays legend
	&dash();
	$index = 1;																							#sets index to 1
	foreach $content2(@content2)							#iterates through all of the accounts stored in content2(decrypted array)
	{
		($app,$username,$password) = split(/,/, $content2);	#splits every element in content2(decrypted array) on a comma and assigns
																				#them into $app, $username, $password
		$censor = substr $password,0,3;								#applies filters for the password, application name and username so they
																				#don't mess up the formatting of the menus
		$star = "****";
		$aLimit = substr $app,0,17;
		$uLimit = substr $username,0,17;
		$censoredPass = $censor.$star;
		printf ("\t| [%2d] %-17s %-17s %-16s%-1s\n", $index, $aLimit, $uLimit, $censoredPass, "|");
		$index++;                                   #auto increments for every account that is displayed so each account gets it's own index
	}
	
	$length = @content;										#gets length of content(encrypted array) for error checking
	
	&dash();

	print "\t| Please select the index you wish to remove or [Q] to Quit|\n\t\t";	#prompts user to select the index of the 
																											#account they want to remove
	chomp ($input = <STDIN>);																		#reads from STDIN and assigns into $input
	
	SWITCH:					#this switches main purpose is for error checking the users input to make sure it is a number within range
	{
		($input =~ /q/i) and do												#option 1: will quit to main menu if users input is q (ignores case)
		{
			print "\t  Returning to Main Menu\n";
			sleep 2;
			&mainMenu();
			last;
		};
		($input eq '') and do												#option 2: error check for enter or empty string
		{
			print "\n\tError, Invalid index\n";
			sleep 2;
			system "clear";
			&manageRemove();
			last;
		};
		($input =~ /\D/ || $input =~ /\s/) and do						#option 3: error check for anything that is not a digit or white space
		{
			print "\n\tError, Invalid index\n";
			sleep 2;
			system "clear";
			&manageRemove();
			last;
		};
		($input > $length || $input < 0) and do					#option 4: error check for any number over the amount of acounts in the array
		{
			print "\n\tError, Invalid index\n";
			sleep 2;
			system "clear";
			&manageRemove();
			last;
		};
		($input == 0) and do												#Because we $input--, we have to take into account -1 index (R-INDEX).
		{																		#(Which would normally delete the last index of the array if $input == 0)
			print "\n\tError, Invalid index\n";
			sleep 2;
			system "clear";
			&manageRemove();
			last;
		};
		{
			print"\t| Are you sure you want to remove this account?            |\n ";
			print"\t| [Y] for Yes                                              |\n ";
			print"\t| [N] To NOT remove account                                |\n\t\t";
			chomp($option = <STDIN>);								#reads from STDIN and assigns into $option
			SWITCH:														#this switch is for a simple double check for the user incase they missclicked
			{
				($option =~ /y/i) and do
				{
					$input--;											#de-increments index to match the correct index in the array
					splice (@content, $input, 1);			#splice statment used to edit the array and remove the specified account from the array
					printf "\t  [%2d] has been removed!\n", ($input + 1);
					sleep 2;
					&writeFile();										#opens pass.rpt to write (writes to file because it needs to overwrite all
																			#previous data in file file and replce it with the new edited array)
					foreach $content(@content)						#prints each account into the file
					{
						print OUTFILE "$content\n";
					}
					&manageRemove();									#calls manageRemove sub at end incase they want to remove another account
					last;
				};
				($option =~ /n/i) and do							#if user inputs n it does not remove the account and calls the manageRemove sub	
				{															#incase they want to remove another account or quit
					&manageRemove();
					last;
				};
				{
					print("\n\tError, Invalid option\n");										#errors if input is not either n or y
					sleep(2);
					&manageRemove();
					last;
				};
			};
		};
	}
}

sub manageRemoveHeader                                                           #Remove Accounts Header Subroutine
{
    print "
	| PassCache |                                 | $date |
	*----------------------------------------------------------*
	|                    Remove Account(s)                     |
	|----------------------------------------------------------|";                #Used to re-display Remove Accounts Header
}

sub manageEdit																							#Edit Accounts Subroutine
{
	my($censor,
		$censoredPass,
		$star,
		$selected,																	#stores the account the user selected
		$newSelected,																#stores the edited account that the user previously selected
		%data,
		$data,
		$key, 																		#used inconjunction with %data hash to display values of hash
		$check);
		
	$option = 0; 																	#used to reset loops
	$check = "n";			#initialized as "n" [no] this value does not change until the user enters y which exits them from the while loop
	
	system "clear";
	&decrypt();																		#decrpts pass.rpt file and stores decrypted data in content2 array
	&manageEditHeader();															#calls for manageEditHeader and displays menu	  
	print "\n\t| Displaying all accounts (Website|Username|Password):     |\n";
	&dash();
	print "\t| [ #]   Website/App   |    Username     |   Password      |\n";		#displays legend
	&dash();
	$index = 1;																							#sets index to 1
	foreach $content2(@content2)											#iterates through all of the accounts stored in content2(decrypted array)
	{
		($app,$username,$password) = split(/,/, $content2);		#splits every element in content2(decrypted array) on a comma and assigns
																					#them into $app, $username, $password
		$censor = substr $password,0,3;									#applies filters for the password, application name and username so they
		 																			#don't mess up the formatting of the menus
		$star = "****";
		$aLimit = substr $app,0,17;
		$uLimit = substr $username,0,17;
		$censoredPass = $censor.$star;
		printf ("\t| [%2d] %-17s %-17s %-16s%-1s\n", $index, $aLimit, $uLimit, $censoredPass, "|");
		$index++;											#auto increments for every account that is displayed so each account gets it's own index
	}
	
	$length = @content;														#gets length of content(encrypted array) for error checking
	
	&dash();

	print "\t| Please select the index you wish to edit or [Q] to Quit  |\n\t\t";
	chomp ($input = <STDIN>);												#reads in STDIN and assigns in to $input
	SWITCH:					#this switches main purpose is for error checking the users input to make sure it is a number within range
	{
		($input =~ /q/i) and do											#option 1: will quit to main menu if users input is q (ignores case)	
		{
			print "\t  Returning to Main Menu\n";
			sleep 2;
			&mainMenu();
			last;
		};
		($input eq '') and do											#option 2: error check for enter or empty string
		{
			print "\n\tError, Invalid index\n";
			sleep 2;
			system "clear";
			&manageEdit();
			last;
		};
		($input =~ /\D/ || $input =~ /\s/) and do					#option 3: error check for anything that is not a digit or white space
		{
			print "\n\tError, Invalid index\n";
			sleep 2;
			system "clear";
			&manageEdit();
			last;
		};
		($input > $length || $input < 0) and do					#option 4: error check for any number over the amount of acounts in the array
		{
			print "\n\tError, Invalid index\n";
			sleep 2;
			system "clear";
			&manageEdit();
			last;
		};
		($input == 0) and do												#Because we $input--, we have to take into account -1 index (R-INDEX).
	 																			#(Which would normally delete the last index of the array if $input == 0)
		{
			print "\n\tError, Invalid index\n";
			sleep 2;
			system "clear";
			&manageEdit();
			last;
		};
		{
			$input--;														#de-increments input so it will have the right index in the array
			$selected = ($content [$input]);							#slices the account from the array using the users input as the index
			&dash();
			printf "\t| Now Editing #[%2s]:                                       |\n", ($input + 1);
			($app,$username,$password) = split(/\./, $selected);	#splits the selected account into it's respective variables
			&dash();
			print "\t| Please select one of the following you wish edit         |";
			print "\n\t|  Website/App [1]  |  Username/Email [2] |  Password [3]  |\n\t\t";
			chomp ($option = <STDIN>);									#gets user input for what part of the account that they want to edit
		
			while($check =~ /n/i)								#user will stay in while loop until they enter yes during secondary verification
			{
				SWITCH:
				{
					($option == 1) and do								#option 1: user will edit application name
					{
						system("clear");
						&manageEditHeader();
						printf "\n\t| Please Enter Website\\App for #[%2d]:                      |\n\t\t", ($input + 1);
						chomp ($app = <STDIN>);							#user enters application name that they want to replace with the previous one
						print "\t| Are you sure about these changes? Enter (Yes [Y] or No [N]): \n\t\t";
						chomp ($check = <STDIN>);						#verifies that they did not miss click and are happy with inputted value
						$app = &encryptEditA();			#calls encryption sub for application name and assigns the returned value back into $app
						last;
					};
					($option == 2) and do															#option 2: user will edit username
					{
						system("clear");
						&manageEditHeader();
						printf "\n\t| Please Enter Username\\Email for #[%2d]:                   |\n\t\t", ($input + 1);
						chomp ($username = <STDIN>);					#user enters  username that they want to replace with the previous one
						print "\t| Are you sure about these changes? Enter (Yes [Y] or No [N]): \n\t\t";
						chomp ($check = <STDIN>);						#verifies that they did not miss click and are happy with inputted value
						$username = &encryptEditU();	#calls encryption sub for username and assigns the returned value back into $username
						last;
					};
					($option == 3) and do															#option 3: user will edit password
					{
						system("clear");
						&manageEditHeader();
						printf "\n\t| Please Enter Password for #[%2d]:                          |\n\t\t", ($input + 1);
						chomp ($password = <STDIN>);					#user enters password that they want to replace with the previous one
						print "\t| Are you sure about these changes? Enter (Yes [Y] or No [N]): \n\t\t";
						chomp ($check = <STDIN>);						#verifies that they did not miss click and are happy with inputted value
						$password = &encryptEditP();		#calls encryption sub for password and assigns the returned value back into $password
						last;
						};
					($option == 4) and do
					{
						&manageEdit();
						last;
					};
					{
						print "\n\tError, Invalid Option\n";	#error incase the user inputs something that was not specified on the menu
						sleep (2);
						$option = 4;
						&manageEdit();
						last;
					};
				}
				system "clear";																		
				if ($check =~ /y/i)						#takes input from verification in the switch above and uses that to step into if statement
				{
				%data = (
							Name => $username,
							Pass => $password,
							App => $app);
				foreach $key (sort keys %data)					#iterates through hash and sorts values into the order app, name, pass
				{
					$newSelected .= "$data{$key}.";			#concatinates each value in hash into new variable with a period at the end of each
				}
				chop $newSelected;																	#gets rid of the last period
				splice (@content, $input, 1, $newSelected);									#splices new edited account info into the content array
				&writeFile();										#opens pass.rpt to write (writes to file because it needs to overwrite all previous
																		#data in file and replce it with the new edited array)
					foreach $content(@content)														#prints accounts into pass.rpt file
					{
						print OUTFILE "$content\n";
					}
				printf "
	                                              | $date |
	*----------------------------------------------------------*
	|                         PassCache                        |
	|----------------------------------------------------------|
	|                                                          |
	|        [#%2d] account has been successfully edited        |
	|                                                          |
	|              Returning you back to Edit Menu             |
	|                                                          |
	|                                                          |
	*----------------------------------------------------------*
				", ($input + 1);									#message showing which account was successfully added/edited
				sleep (2);
				system ("clear");
				&manageEdit();										#calls manageEdit at end so the user can quit or edit another account
				}
			}
			last;
		};
	}
}

sub manageEditHeader                                                             #Edit Accounts Header Subroutine
{
	print "
	| PassCache |                                 | $date |
	*----------------------------------------------------------*
	|                      Edit Account(s)                     |
	|----------------------------------------------------------|";                #Used to re-display Edit Accounts Header
}

sub quit																									#Quit Subroutine
{
	system ("clear");
	print "
	                                              | $date |
	*----------------------------------------------------------*
	|                         PassCache                        |
	|----------------------------------------------------------|
	|                                                          |
	|                                                          |
	|     Thank you for using PassCache, goodbye for now.      |
	|                                                          |
	|                                                          |
	|                                                          |
	*----------------------------------------------------------*
	";																										#Display goodbye screen
	sleep 3;
	system ("clear");
}

sub search																								#Search Subroutine
{
	system("clear");
	&manageSearchHeader();																			#calls manageSearchHeader sub and displays header
	$index = 1;																							#sets index to 1
	print"\n\t| Enter the account you are trying to look for             |\n";
	&dash();
	print"\t| If no accounts are printed,                              |\n";
	print"\t| no account of that name is stored                        |\n";
	&dash();
	print"\t| Enter account name by either Website or Username:        |\n\t\t"; 
	chomp($search = <STDIN>);							#reads from STDIN and assign input into $search variable
	@searchContent = ();									#since this search function loops we need to reset the searchContent array every iteration
	&decrypt();								#reads all info from pass.rpt file into array then decrypts that array and assigns it into @content2
	&dash();
	print "\t| [ #]      Website/App       |          Username          |\n";		#prints legend
	&dash();
	foreach(@content2)									#used to iterate the amount of times there are elements in the array (#of accounts)
	{
		if(/$search/i)			 							#main search function (ignores characters)
		{
			($app,$username,$password) = split(/,/, $_);		#splits every element that matches the search criteria the special variable
										 									#stores each account that matches the pattern
			$aLimit = substr $app,0,17;							#applies filters for the password, application name and username so they don't
				 															#mess up the formatting of the menus
			$uLimit = substr $username,0,20;
			push(@searchContent, $password);						#pushes every password of the matching accounts into the searchContent array 
																			#(we need to do this so the user can properly find the password that coresponds
																			#with the account of screen)
			printf ("\t| [%2d] %-23s %-27s |\n", $index, $aLimit, $uLimit);		#only prints account index, application and password
			$index++; 								
			#auto increments for every account that is displayed so each account gets it's own index	      
		}
	}
	&optionSearchMenu();												#calls optionSearchMenu sub this sub is in charge of allowing the user to pick
	 																		#the account that they want to see the password too
}
	

sub optionSearchMenu																					#optionSearchMenu
{
	my(@slice);												#@slice used for obtaining the selected account the user wants to see the password too
	
	print "\t| Please select the index you wish to see the passsword of |\n";
	print "\t| an account or [Q] to Quit:                               |\n\t\t";
	chomp ($input = <STDIN>);
	
	$length = @searchContent; 										#gets amount of elements in array for error checking the users input
	
	if($input =~ /q/i) 												#option 1: will quit to main menu if users input is q (ignores case)	
	{
		print "\tReturning to Main Menu\n";																				
		sleep 2;
		&mainMenu();
	}
	elsif ($input eq '')												#option 2: error check for enter or empty string
	{
		print "\n\tError, Invalid index\n";
		sleep 2;
		&searchDisplayMenu();										#calls searchDisplayMenu sub to re-display accounts menu
		&optionSearchMenu();											#calls optionSearchMenu sub
	} 
	elsif ($input =~ /\D/ || $input =~ /\s/)					#option 3: error check for anything that is not a digit or white space
	{
		print "\n\tError, Invalid index\n";
		sleep 2;
		&searchDisplayMenu();
		&optionSearchMenu();
	}
	elsif ($input > $length || $input < 0) 					#option 4: error check for any number over the amount of acounts in the array
	{
		print "\n\tError, Invalid index\n";
		sleep 2;
		&searchDisplayMenu();
		&optionSearchMenu();
	}
	elsif ($input == 0)												#Because we $input--, we have to take into account -1 index (R-INDEX). 
																			#(Which would normally delete the last index of the array if $input == 0)
	{
		print "\n\tError, Invalid index\n";
		sleep 2;
		&searchDisplayMenu();
		&optionSearchMenu();
	} 
	else
	{
		$input--;
		chomp(@slice = ($searchContent[$input]));				#takes the index that the user input and slices the password for that 
																			#account into the slice array
		$input++;
		print("\t| Password for Index [#$input] is @slice |\n");		#displays the password and the account number the password corrilates to
		print("\t  Hit enter when done\n\t\t");
		$empty = <STDIN>;															#an empty varible used to stop the program until the user hits enter
		 																				#(this gives the user time to see there password)
		&searchDisplayMenu();
		&optionSearchMenu();
	}
	
}

sub manageSearchHeader                                                    			#Search Accounts Header Subroutine
{
	print "
	| PassCache |                                 | $date |
	*----------------------------------------------------------*
	|                    Search Account(s)                     |
	|----------------------------------------------------------|";       			#Used to re-display Search Accounts Header
}

sub searchDisplayMenu															#searchDisplayMenu subroutine (this subroutine does not ask for user 
{																						#input because it is only incharge of displaying the previous account
 																						#screen with the same search parameters)
	system("clear");
	&manageSearchHeader();
	print "\n\t| [ #]      Website/App       |          Username          |\n";
	&dash();
	@searchContent = ();
	$index = 1;
	foreach(@content2)
	{
		if(/$search/i)			 														
		{
			($app,$username,$password) = split(/,/, $_);					#splits every element that matches the search criteria the special
			 																			#variable stores each account that matches the pattern
			$aLimit = substr $app,0,17;										#applies filters for the password, application name and username so
			 																			#they don't mess up the formatting of the menus
			$uLimit = substr $username,0,20;
			push(@searchContent, $password);
			printf ("\t| [%2d] %-23s %-27s |\n", $index, $aLimit, $uLimit);			#prints menu
			$index++;       
		}
	}
}

sub date																									#Date Subroutine 
{
	my(@now,
		$now,
		$date);
		
	$now = `date`;
	@now = split / /,$now;
	if ($now[2] eq "")
	{
		@now =($now[1],$now[3],$now[6]);
	}
	else
	{
		@now = ($now[1],$now[2],$now[5]);
	}
	$date = join " ",@now;
	return $date;
}	

sub passFile																		#appends data to pass.rpt file		
{
	open(OUTFILE, ">>/root/passCache/pass.rpt") || die "Cannot open pass.rpt file, died on line $!";
}

sub closePassFile 																#closes pass.rpt file
{
	close(OUTFILE);
}

sub readWriteFile 																#read and write to pass.rpt file
{
	open(OUTFILE, "+</root/passCache/pass.rpt") || die "Cannot open pass.rpt file, died on line $!";
}

sub writeFile 																		#only writes to pass.rpt file 
{
    open(OUTFILE, ">/root/passCache/pass.rpt") || die "Cannot open pass.rpt file, died on line $!";
} 

sub readwriteCheck 																					#read and write to masterPass.txt file
{
	open(CHECKPASS, "+</root/passCache/masterPass.txt") || die "Cannot open masterPass.txt file, died on line $!";
}

sub dash																									#Dash Subroutine
{	
	my $dash = "-" x 58;															#Used to display a dashed divider for options and other misc
	chomp $dash;
	print "\t|$dash|\n";
}

sub manageAddHeader																					#Add Accounts Header Subroutine
{
	print "
	| PassCache |                                 | $date |
	*----------------------------------------------------------*
	|                      Add Account(s)                      |
	|----------------------------------------------------------|				\n";	#Used to re-display Add Accounts Header
}

sub decrypt																								#Decrypt Subroutine
{
	my($char,																							#used to store each character for character shifting
		@empty,																							#used to overwrite temp file after decrypt is done
		$empty);																							
	
	open(READ, "/root/passCache/pass.rpt") || die "Cannot open temp.txt file, died on line $!";#opens pass.rpt file to read only
	chomp (@content = <READ>);																			#reads all info from pass.rpt into @content array
	close READ;																							
	open(OUTFILE, "+</root/passCache/temp.txt") || die "Cannot open temp.txt file, died on line $!";#opens temp.txt file to read write
	foreach $content(@content)																			#iterates for the #of accounts in the @content array
	{
		foreach $char(split //, $content)														#iterates for the amount of splits on nothing 
   	{																									#(this seperates each character so every character can
   																										#be shifted)
			$char = ord($char) -2;																		#turns character into an ord value and minus by 2
     		$char = chr($char);																			#turns ord values back into a character
			print OUTFILE "$char";																		#prints that character to a file
   	}
   	print OUTFILE "\n";	#prints a \n after every account has been shifted back to normal (this puts each account on it's own line)
   }
   @content2 = <OUTFILE>;																				#reads decrpyted data from temp.txt
   close OUTFILE;																							#closes temp.txt
   
   open(READ, "/root/passCache/temp.txt") || die "Cannot open temp.txt file, died on line $!";#opens temp.txt as read only
   @content2 = <READ>;																					#reads info from temp.txt to @content2
   close READ;
   open(OUTFILE, ">/root/passCache/temp.txt") || die "Cannot open temp.txt file, died on line $!";#opens temp.txt as write only
   @empty = ();																							#initializes @empty to empty
   print OUTFILE @empty;											#this allows us to write this empty array into the file effectivley erasing it
   close OUTFILE;
   return @content2;																						#returns the content2 array
}

sub passDecrypt				#passDecrypt has the same functionality as the decrypt sub just with a reset at the start
{
	my($char,
		@empty,
		$empty);
	
	@content2=();													#sub is used multiple times so it needs to reset content2 everytime it is called
	open(READ, "/root/passCache/masterPass.txt") || die "Cannot open masterPass.txt file, died on line $!";
	chomp (@content = <READ>);
	close READ;
	open(OUTFILE, "+</root/passCache/temp.txt") || die "Cannot open temp.txt file, died on line $!";
	foreach $content(@content)
	{
		foreach $char(split //, $content)
   	{
			$char = ord($char) -2;
     		$char = chr($char);
			print OUTFILE "$char";
   	}
   	print OUTFILE "\n";
   }
   @content2 = <OUTFILE>;
   close OUTFILE;
   
   open(READ, "/root/passCache/temp.txt") || die "Cannot open temp.txt file, died on line $!";
   @content2 = <READ>;
   close READ;
   open(OUTFILE, ">/root/passCache/temp.txt") || die "Cannot open temp.txt file, died on line $!";
   @empty = ();
   print OUTFILE @empty;
   close OUTFILE;
   return @content2;
}

sub encryptApp							#encrypt Application subroutine (incharge of encrypting the application name for add accounts)
{
	foreach $split(split //, $app)											#for every split on nothing shift the character by 2
	{
		$split = ord($split) +2;												#changes character to ord value and adds 2
		printf OUTFILE "%c", $split;											#prints ord value as a character to pass.rpt file
	}
	print OUTFILE (".");				#prints a period after application name is done being encrpted to be used in split
}

sub encryptPass						#encrypt Password subroutine (incharge of encrypting the password for add accounts)
{
	foreach $split(split //, $password)										#for every split on nothing shift the character by 2
	{
		$split = ord($split) +2;												#changes character to ord value and adds 2
		printf OUTFILE "%c", $split;											#prints ord value as a character to pass.rpt file	
	}	#unlike application and username it does not print a period after the variable because password is added last into the file
}

sub encryptUser						#encrypt Username subroutine (incharge of encrypting the username for add accounts)
{
	foreach $split(split //, $username)										#for every split on nothing shift the character by 2
	{
		$split = ord($split) +2;												#changes character to ord value and adds 2
		printf OUTFILE "%c", $split;											#prints ord value as a character to pass.rpt file	
	}
	print OUTFILE (".");				#prints a period after application name is done being encrpted to be used in split
}

sub encryptEditU						#encrypt Edit Username subroutine (incharge of encrypting the username for Edit accounts)
{
	$Encrypt = ();						#resets $Encrypt because the user can edit multiple accounts so it needs to reset for each iteration
	foreach $split(split //, $username)										#for every split on nothing shift the character by 2
	{
		$split = ord($split) +2;												#changes character to ord value and adds 2
		$split = chr($split);													#changes ord value back to character
		$Encrypt .= $split;			#concatinates (adds) each character into $Encrypt making the full encrpyted username when done iterating
	}
	return $Encrypt;					#returns $Encrypt value
}

sub encryptEditA						#encrypt Edit Application subroutine (incharge of encrypting the application name for Edit accounts)
{
	$Encrypt = ();						#resets $Encrypt because the user can edit multiple accounts so it needs to reset for each iteration
	foreach $split(split //, $app)											#for every split on nothing shift the character by 2
	{
		$split = ord($split) +2;												#changes character to ord value and adds 2
		$split = chr($split);													#changes ord value back to character
		$Encrypt .= $split;			#concatinates (adds) each character into $Encrypt making the full encrpyted 
											#application name when done iterating
	}
	return $Encrypt;					#returns $Encrypt value
}

sub encryptEditP						#encrypt Edit Password subroutine (incharge of encrypting the password for Edit accounts)
{
	$Encrypt = ();						#resets $Encrypt because the user can edit multiple accounts so it needs to reset for each iteration
	foreach $split(split //, $password)										#for every split on nothing shift the character by 2
	{
		$split = ord($split) +2;												#changes character to ord value and adds 2						
		$split = chr($split);													#changes ord value back to character
		$Encrypt .= $split;			#concatinates (adds) each character into $Encrypt making the full encrpyted 
											#application name when done iterating
	}
	return $Encrypt;					#returns $Encrypt value
}

sub encryptEmail						#encrypt Edit Password subroutine (incharge of encrypting the password for Edit accounts)
{
	$Encrypt = ();						#resets $Encrypt because the user can edit multiple accounts so it needs to reset for each iteration
	foreach $split(split //, $email)										#for every split on nothing shift the character by 2
	{
		$split = ord($split) +2;												#changes character to ord value and adds 2						
		$split = chr($split);													#changes ord value back to character
		$Encrypt .= $split;			#concatinates (adds) each character into $Encrypt making the full encrpyted 
											#application name when done iterating
	}
	return $Encrypt;					#returns $Encrypt value
}

sub authen
{
	@char_list=('0'..'9');				
	$pin = 0;
	
	for(1..8)					#uses user input to set number of iterations
	{
	   $pin .= $char_list[rand @char_list]; #gets random index from array of characters and concatintes them into $passsword
	}
	
	return($pin);
}


