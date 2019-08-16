# ubx-parser
U-blox binary file parser.

Supports the latest [U-blox protocol 8](https://www.u-blox.com/sites/default/files/products/documents/u-blox8-M8_ReceiverDescrProtSpec_%28UBX-13003221%29_Public.pdf) specifications.

Supported messages:
* NAV-SAT
* RXM-RAWX

## Architecture
![parser architecture](https://gitlab.esa.int/galileo-receiver-activities/ubx-parser/raw/master/doc/arch.png)

## Install 
```
git clone https://gitlab.esa.int/galileo-receiver-activities/ubx-parser.git
```

## Usage

```Matlab
cds = parseUbxFile('ubxlog.ubx');

[cds, cells] = parseUbxFile('ubxlog.ubx');
```

## APIs

### ok = checksum(buffer)
Computes the checksum of `buffer` using the Fletcher algorithm and returns `true` iff the checksum is valid.
`buffer` is a `byte array` 

### msgs = filterMsg(cells, classId, msgId
Filters messages based on `classId` and `msgId`. Returns a `struct array`

### field = getSvField(msgs, fieldIn, fieldOut)	
gets field and associates it with the proper SVs. Returns a `struct array` containing the following fields:
* `['gps' fieldOut]`
* `['gal' fieldOut]`
* `['glo' fieldOut]`
If `fieldOut` is not specified, `fieldOut` will assume the same value as `fieldIn`.

### ts = getTimescale(rxmrawx)		
gets the timescale from RXM-RAWX messages. `rxmrawx` is a `struct array`. Returns an `array`.

### [cds, cells] = parse(buffer, opts)
parses U-blox binary buffers. `buffer` is a `byte array`, `opts` is reserved for the future.
Returns a `CDS struct`. The second output argument is optional and contains a `cell array` of parsed messages.

### msg = parseNAV(payload, msgId)
parses a NAV message. `payload` is the payload of the NAV frame. `msgId` is the message Id of the NAV frame.
Returns a `struct`.

### parseRXM(payload, msgId)
parses a NAV message. `payload` is the payload of the RXM frame. `msgId` is the message Id of the RXM frame.
Returns a `struct`.

### [cds, cells] = parseUbxFile(fname, opts)
parses U-blox binary file. `fname` is `string` containing the path of the ubx file, `opts` is reserved for the future.
Returns a `CDS struct`. The second output argument is optional and contains a `cell array` of parsed messages.

### n = sizeof(ubxType)
gets the size of an `ubxType` in bytes

### cds = toCds(cells)
converts messages to CDS. `cells` is a `cell array` containing parsed messages.
Returns a `CDS struct`.

### matlabType = typeConv(ubxType, buffer, offset)
converts `ubxType` to `MATLAB`. `ubxType` is an U-blox data type, `buffer` is a `byte array`, `offset` is a `positive integer`.
Returns a `MATLAB` type obtained by converting the U-blox data type at `buffer(1+offset)`.



