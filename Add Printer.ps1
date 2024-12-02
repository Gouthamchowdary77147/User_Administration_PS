# Define the printer details
$PrinterName = "19 RICOH"  # Provide a name for the printer
$PrinterIPAddress = "192.168.140.2"  # Replace with the printer's IP address
$DriverPath = "C:\Windows\System32\DriverStore\FileRepository\prnms012.inf_amd64_511872a9cbe5683d"  # Provide the path to the printer driver

# Create a new TCP/IP printer port
$PortName = "IP_$PrinterIPAddress"
Add-PrinterPort -Name $PortName -PrinterHostAddress $PrinterIPAddress

# Install the printer using the TCP/IP port and driver
Add-Printer -Name $PrinterName -PortName $PortName -DriverName "Microsoft IPP Class Driver"  # Specify the driver name
