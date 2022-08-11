## SQL Injection using sqlmap
- Can use when URL vulnerable to SQL injection and find its corresponding cookie value

- Listing out all databases
	- Provide `url` and `cookie` as possible parameters
```
sudo sqlmap –u "<url>" --cookie="<cookie>" --dbs
```

- List out all information given a table name
```
sudo sqlmap -u "<url>" --cookie="<cookie>" -T <table name> --dump
```

- List out all information on a given database name
```
sudo sqlmap -u "<url>" --cookie="<cookie>" -D <database name> --dump-all
```

- Target a POST request endpoint
	- `request_file` refers to the packet taken using **Burpsuite as a proxy** to the client.
```
sudo sqlmap -r request_file -p target_parameters_from_file --dump
```

## Snort Flags
| Flag           | Argument |
| -------------- | -------- |
| FIN            | F        |
| SYN            | S        |
| RST            | R        |
| PSH            | P        |
| ACK            | A        |
| URG            | U        |
| Reserved Bit 1 | 1        |
| Reserved Bit 2 | 2        |
| No Flag        | 0        | 
