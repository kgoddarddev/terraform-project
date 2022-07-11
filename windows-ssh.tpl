add-content -path C:/users/close/.ssh/config -value '

Host ${hostname}
 HostName ${hostname}
 User ${user}
 IdentityFile ${identityfile}
 '