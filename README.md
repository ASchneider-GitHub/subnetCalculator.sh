# subnetCalculator.sh
## Uses an IP address and a network mask to calculate information about the subnet.

Either displays information in the CLI, or prints the following documents to a user-set path:
- ipInfo.txt {Basic summary of the subnet}
- ipRange.json {Usable JSON file with all host IP addresses listed}
- ReadMe.txt {Gives information on potential host address issues.}

### Current Bugs:
- [ ] Classful netmasks (/8, /16, & /24) result in bad data and script failure. Avoid these masks until further notice.

### Misc. Notes
- ShellCheck command used for code review purposes: `shellcheck --color=always --exclude=SC2039,SC2086,SC2116 [FILEPATH]`
  - Omitted error code summary: 
    - `SC2039`:
      - "In POSIX sh, string indexing is undefined."
      - "In POSIX sh, string replacement is undefined."
      - "In POSIX sh, brace expansion is undefined."
    - `SC2086`: "Double quote to prevent globbing and word splitting.""
    - `SC2116`: "Useless echo? Instead of `cmd $(echo foo)`, just use `cmd foo`."
    
- Website used to verify accuracy of calculations: [Online Subnet Calculator](https://www.tunnelsup.com/subnet-calculator/)