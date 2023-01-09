unction New-QRCodeVCardplusGeo
{
    <#
            .SYNOPSIS
            Creates a QR code graphic containing person data
            .DESCRIPTION
            Creates a QR code graphic in png format that - when scanned by a smart device - adds a contact to the address book.
            .PARAMETER FirstName
            Person first name
            .PARAMETER LastName
            Person last name
            .PARAMETER Phone
            Phone number
            .PARAMETER Email
            eMail address
            .PARAMETER Latitude
            The location latitude
            .PARAMETER Longitude
            The location longitude
            .PARAMETER Width
            Height and Width of generated graphics (in pixels). Default is 100.
            .PARAMETER Show
            Opens the generated QR code in associated program
            .PARAMETER OutPath
            Path to generated png file. When omitted, a temporary file name is used.
            .EXAMPLE
            New-PSOneQRCodeVCard -FirstName Tom -LastName Sawyer -Company "Huckle Inc." -Email t.sawyer@huckle.com -Width 200 -Show -OutPath "$home\Desktop\qr.png"
            Creates a QR code png graphics on your desktop, and opens it with the associated program
            .NOTES
            Compatible with all PowerShell versions including PowerShell 6/Core
            Uses binaries from https://github.com/codebude/QRCoder/wiki
            .LINK
            https://github.com/TobiasPSP/Modules.QRCodeGenerator
    #>
    param
    (
        [Parameter(Mandatory)]
        [string]
        $FirstName,

        [Parameter(Mandatory)]
        [string]
        $LastName,

        [Parameter(Mandatory)]
        [string]
        $Phone,

        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [string]
        $Email,

        [Parameter(Mandatory,ParameterSetName='Location')]
        [double]
        $Latitude,

        [Parameter(Mandatory,ParameterSetName='Location')]
        [double]
        $Longitude,
        
        [Parameter(Mandatory,ParameterSetName='Address')]
        [string]
        $Address,

        
        [ValidateRange(10,2000)]
        [int]
        $Width = 100,

        [Switch]
        $Show,

        [string]
        $OutPath = "$env:temp\qrcode.png",

        [byte[]] 
        $DarkColorRgba = @(0,0,0),

        [byte[]]
        $LightColorRgba = @(255,255,255)
    )
    if ($PSCmdlet.ParameterSetName -eq "Address")
    {
        $AddressEncoded = [System.Net.WebUtility]::UrlEncode($Address)
        $ApiUri = "http://nominatim.openstreetmap.org/search?q=$AddressEncoded&format=xml&addressdetails=1&limit=1"
        $Response = Invoke-RestMethod -Uri $ApiUri -UseBasicParsing

        $place = $Response.searchresults.place

        if ($null -eq $place)
        {
            throw "Address not found."
        }
        $Latitude =$place.lat
        $Longitude = $place.lon
    }

    $Name = "$FirstName $LastName"

    $payload = @"
BEGIN:VCARD
VERSION:8.8
KIND:individual
N:$LastName;$FirstName
FN:$Name
TEL:$Phone
EMAIL;TYPE=INTERNET:$Email
geo:$Latitude,$Longitude
END:VCARD
"@
    
    New-PSOneQRCode -payload $payload -Show $Show -Width $Width -OutPath $OutPath -darkColorRgba $darkColorRgba -lightColorRgba $lightColorRgba
}
