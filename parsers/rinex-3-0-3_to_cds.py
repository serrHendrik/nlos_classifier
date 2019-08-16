"""Script to parse RINEX-3-0-3 files into Common-Data-Structure
Paramaters
==========

Detail
======

Limitation
==========
    * [getLeapSeconds][]: by nature this function must be updated with possible future UTC leap second dates
        * will raise eception if leap second information are not valid anymore
    * only OBSERVATION and EPOCH records implemented (special records and cycle slip TBDiscussed)

Changelog
=========
    * 2018-06: Adapted parsing for negative values on L/S observables and overwriting 0.000/-100 values to NaN to cover IfenSX3 RINEX files
"""

import re
import sys
import os.path
import datetime
import numpy as np
from scipy import io
from decimal import Decimal

# DEBUG
import time

#.rinex/FOCTURNv2/3-0-3_chNum/FOC-1160.16O

pattern_header_split = r"^(?P<header_data>.{60})(?P<header_label>.{5,20})$"
re_header_split = re.compile( pattern_header_split )

pattern_sysObsType = r"^(?P<sys>.{1})  (?P<obsCount>.{3})( .{3})( .{3})( .{3})( .{3})( .{3})( .{3})( .{3})( .{3})( .{3})( .{3})( .{3})( .{3})( .{3})  $"
re_sysObsType = re.compile( pattern_sysObsType )

sysObsTypes = { 'SYSs': [ 'G', 'E', 'R', 'J', 'C', 'I', 'S' ],
                'OBS_TYPESs': { 'C': "",
                                'L': "",
                                'D': "",
                                'S': "",
                                'I': "",
                                'X': "" }
                }

#obsTypesDecode = {  'C': r"(?P<#OBS>[\s\d]{10}\.[\s\d]{3}).(?P<#SSI>.)",
#                    'L': r"(?P<#OBS>[\s\d]{10}\.[\s\d]{3})(?P<#LLI>.)(?P<#SSI>.)",
#                    'D': r"(?P<#OBS>[-\s\d]{10}\.[\s\d]{3}).(?P<#SSI>.)",
#                    'S': r"(?P<#OBS>[\s\d]{10}\.[\s\d]{3}) {0,2}",
#                    'I': r"(?P<#OBS>[\s\d]{10}\.[\s\d]{3}).{0,2}",
#                    'X': r"(?P<#OBS>[\s\d]{10}\.[\s\d]{3}) {0,2}" }
obsTypesDecode = {  'C': r"((?P<#OBS>[\s\d]{10}[\s\.][\s\d]{3}).(?P<#SSI>.))?",
                    'L': r"((?P<#OBS>[-\s\d]{10}[\s\.][\s\d]{3})(?P<#LLI>.)(?P<#SSI>.))?",
                    'D': r"((?P<#OBS>[-\s\d]{10}[\s\.][\s\d]{3}).(?P<#SSI>.))?",
                    'S': r"((?P<#OBS>[-\s\d]{10}[\s\.][\s\d]{3}) {0,2})?",
                    'I': r"((?P<#OBS>[\s\d]{10}[\s\.][\s\d]{3}).{0,2})?",
                    'X': r"((?P<#OBS>[\s\d]{10}[\s\.][\s\d]{3}) {0,2})?" }


re_id = re.compile(r"^> ([\s\d]{4}) ([\s\d]{1,2}) ([\s\d]{1,2}) ([\s\d]{1,2}) ([\s\d]{1,2}) ([\s\d]{1,2}).([\s\d]{7})  (\d)(.*)")
re_timeOfFirstObs = re.compile(r"(?P<year>.{6})(?P<month>.{6})(?P<day>.{6})(?P<hour>.{6})(?P<min>.{6})(?P<sec>.{13})     (?P<timeSystem>.{3}).*")
re_obs_sv = re.compile(r"^[GERJCISM][\s\d]{2}")

def check( argv ):
    """Checks proper script call"""
    #Param exists
    if len(argv) < 2:
        raise Exception("Usage: "+argv[0]+" <rinex obs file>")
    #File exists
    filePath = argv[1]
    if not os.path.exists(filePath):
        raise Exception("Must be a falid file: "+filePath)
    return filePath


def getSysObsTypes( data ):
    """Extracts 'SYS / # / OBS TYPES' fields from rinex using RE pattern"""
    match = re_sysObsType.match( data )
    if not match:
        raise Exception("SYS / # / OBS TYPES Line not conform to RINEX 3: "+data)
    sysField = match.group(1)
    sys = sysField.replace(" ", "")
    obsCountField = match.group(2)
    obsCount = obsCountField.replace(" ", "")
    obsCount = int( 0 if not obsCount else obsCount )
    obsTypes = []
    for groupNumber in range(3, 13+3):
        field = match.group(groupNumber)
        obsType = field.replace(" ", "")
        if not obsType:
            break
        obsTypes.append( obsType )
    entries = len(obsTypes)
    return (sys, obsCount, obsTypes)


def getTimeOfFirstObs( data ):
    """Extracts 'TIME OF FIRST OBS' fields from rinex using RE pattern"""
    match = re_timeOfFirstObs.match( data )
    if not match:
        raise Exception("TIME OF FIRST OBS Line not conform to RINEX 3: "+data)
    parseDict = {'year': int, 'month': int, 'day': int, 'hour': int, 'min': int, 'sec': float, 'timeSystem': str }
    res = {}
    for key, func in parseDict.items():
        res[key] = func(match.group(key))
    return res


def header( fPath ):
    """Extract information from RINEX-3 header"""
    line_number = 0
    noMatch_lines = 0
    seek_offset = 0

    prevObsSys = 0

    SYS = { "OBS_TYPES": {},
            "DCBS_APPLIED": {} }
    INFO = {};

    with open( fPath ) as fh:
        for line in fh:
            line_number += 1
            seek_offset += len(line)
            match = re_header_split.match(line)

            if not match:
                noMatch_lines
                if noMatch_lines >= 10:
                    raise Exception( "Please check file for correct RINEX header" )
                continue

            data = match.group('header_data')
            label = match.group('header_label')
            label = label.rstrip()

            if line_number == 1:
                if label != "RINEX VERSION / TYPE":
                    raise Exception("First RINEX line must have RINEX VERSION / TYPE at char [61-80]. Is: "+label)

            elif label == "SYS / # / OBS TYPES":
                sys, obsCount, obsTypes = getSysObsTypes( data )
                if not sys and not obsCount and len(obsTypes) > 0:
                    if prevObsSys in SYS["OBS_TYPES"]:
                        SYS["OBS_TYPES"][prevObsSys].extend(obsTypes)
                else:
                    SYS["OBS_TYPES"][sys] = obsTypes
                prevObsSys = sys

            elif label == "TIME OF FIRST OBS":
                INFO['TIME OF FIRST OBS'] = getTimeOfFirstObs( data )

            elif label == "INTERVAL":
                intervalField = data[0:10+1]
                INFO['INTERVAL'] = float( intervalField )

            elif label == "END OF HEADER":
                HEAD = { 'SYS': SYS, 'INFO': INFO }
                return( HEAD )


def getEpochs( fPath ):
    """Returns Number of epochs in Rinex and a array with datetime objects of each avail epoch. Also returns list of svs"""
    epochsDt = []
    svs = []
    N = 0
    epochSVs = []
    multiChannelTracking = []
    with open( fPath ) as fh:
        for line in fh:
            m = re_id.match(line)
            if not m:
                m_sv = re_obs_sv.match(line)
                if N < 1:
                    continue
                if not m_sv:
                    raise Exception("RINEX time record not conform with standard:\n%s" % line)
                sv = m_sv.group( 0 )
                if sv not in svs:
                    svs.append(sv)
                if sv not in multiChannelTracking and sv in epochSVs:
                    multiChannelTracking.append(sv)
#                    print(sv, epochsDt[-1])
                epochSVs.append(sv)
            else:
                results = list(map(int, m.groups()[0:6]))
                epochsDt.append( datetime.datetime( *results[0:6], microsecond=int(m.group(7)[0:6])) )
                N += 1
                epochSVs = []     
    return( N, epochsDt, svs, multiChannelTracking)


def calcRelativeTimesdeltas( rinexEpochsDatetime ):
    """Returns the spacing between consecutive datetime entrys"""
    entryDeltas = np.diff( rinexEpochsDatetime )
    entryDeltaSeconds = [ entryDelta.total_seconds() for entryDelta in entryDeltas ]
    entryDeltaSeconds.insert(0, 0)
    return entryDeltaSeconds 


def checkRinexRate(headerData, entryDeltaSeconds ):
    """Checks for INTERVAL field in header or estimates it from parsed epochs
    Parameters
    ==========
    1. headerData
        * parsed header struct: [see header](#header) 
    2. entryDeltaSeconds
        * seconds between epoch entrys [see calcRelativeTimesdeltas](#calcRelativeTimesdeltas)

    Details
    =======
    Checks header for INTERVAL information (non-mandatory field). If not available estimates the interval by available epochs.

    Returns
    =======
    1. interval: The data rate at which epochs are output
    """
    interval = None
    if 'INTERVAL' in headerData['INFO']:
        interval = headerData['INFO']['INTERVAL']
    else:
        distribution = np.array( [ [rate, entryDeltaSeconds.count(rate)] for rate in set(entryDeltaSeconds) ] )
        interval = distribution[ np.argmax(distribution[:,1]) , 0]
    return interval


def createRelativeEpochs( entryDeltaSeconds, rate ):
    """Creates a linear timescale from entry timespacings and estimated rate
    Parameters
    ==========
    1. entryDeltaSeconds:
        * array with spacing between rinex entrys in seconds [see calcRelativeTimesdeltas](#calcRelativeTimesdeltas)
    2. rate:
        * the (est) datarate [see checkRinexRate](#checkRinexRate)
    
    Returns
    =======
    1. N: Number of epochs
    2. epochs: linear timescale in seconds starting at 0 (offset to first rinex epoch entry)
    """
    if rate >= 1:
        duration = np.round(  np.sum(entryDeltaSeconds), 0 )
    else:
        duration =  np.round(  np.sum(entryDeltaSeconds), 6 )
    N = (Decimal("%.6f" % duration) / Decimal("%.6f" % rate)) + 1
    if ( Decimal("%.6f" % N) % 1 ):
        raise Exception("Number of epochs must be an integer: N = ( duaration / rate) + 1 = (%.20f / %.20f) + 1 = %.20f" % (duration, rate, N) )
    N = int(N)
    epochs = np.linspace( 0, duration, num=N, endpoint=True )
    if not( duration == epochs[-1] ):
        raise Exception("Last linerazed epochs are not matching")
    return N ,epochs


def getLeapSeconds( timepointDatetime ):
    """Returns Leap Seconds valid for the given datetime point (last leap information 2017)"""
    utcLeapSecondsDates = [ "1981-07-01", "1982-07-01", "1983-07-01", "1985-07-01", "1988-01-01", \
                            "1990-01-01", "1991-01-01", "1992-07-01", "1993-07-01", "1994-07-01", "1996-01-01", "1997-07-01", "1999-01-01", \
                            "2006-01-01", "2009-01-01", "2012-07-01", "2015-07-01", "2017-01-01" ]
    validity = 52 #weeks
    utcLeapDates = [ datetime.datetime.strptime(x, "%Y-%m-%d") for x in utcLeapSecondsDates ]
    if timepointDatetime >= (utcLeapDates[-1] + datetime.timedelta( weeks=validity )):
        raise Exception("Please update the code for changes in leap seconds. Update leap table dates or increase validity.")
    leaps = np.sum( timepointDatetime >= np.array(utcLeapDates) )
    return leaps


def calcTimeOffsetToGPS( rinexTimeSystem, rinexFirstObservationDatetime ):
    """Returns linear timescale in seconds since GPS init
    Parameters
    ==========
    1. rinexTimeSystem
        * the time system used. One of: GPS, GAL, GLO, UTC (see RINEX: TIME OF FIRST OBS)
    2. rinexFirstObservationDatetime
        * datetime of first observation entry in the rinex file

    Details
    =======
    GPS System time is selected to be the reference point for all observations in this framework.  

    GPS System time was initiated at 01.06.1980 at midnight from Sat to Sun.  
    Thus the first TOW (second) represents the first second at that Saturaday.  
    Week number count (WNc) incease and TOW reset each Sat to Sun midnight.

    Returns
    =======
    1. offsetTotalSeconds
    2. offsetWNc
    3. offsetTOW
    4. leap
    """
    supportedInputTimeSystems = ['GPS', 'GAL', 'UTC', 'GLO']
    if rinexTimeSystem not in supportedInputTimeSystems:
        raise Exception("Time System conversion from TIME OF FIRST OBS field not supported")

    gpsReferenceDate = datetime.datetime(1980, 1, 6)
    weekSeconds = 3600*24*7
    leap = 0
    if rinexTimeSystem in ['UTC', 'GLO']:
        leap = getLeapSeconds( rinexFirstObservationDatetime )

    offsetDatetime = rinexFirstObservationDatetime - gpsReferenceDate
    offsetTotalSeconds = offsetDatetime.total_seconds()
    offsetTotalSeconds -= leap
    offsetWNc = offsetTotalSeconds // weekSeconds
    offsetTOW = offsetTotalSeconds % weekSeconds
    return( offsetTotalSeconds, offsetWNc, offsetTOW, leap )


def constructObsRecordRe( obsTypes ):
    RES = {}
    for sys, sysObsTypes in obsTypes.items():
        pattern =  r"(?P<SSN>%s[\s\d]{2})" % sys
        for sysObsType in sysObsTypes:
            pattern += obsTypesDecode[ sysObsType[0] ].replace("#", sysObsType)
        RES[sys] = re.compile(pattern)
    return RES

def datetimeToGpsTime( rinexEpochsDatetime, rinexTimeSystem ):
    gpsReferenceDate = datetime.datetime(1980, 1, 6)
    weekSeconds = 3600*24*7
    gpsTime = []
    gpsTOW = []
    gpsWNc = []
    for datetimeEpoch in rinexEpochsDatetime:
        leap = 0
        if rinexTimeSystem in ['UTC', 'GLO']:
            leap = getLeapSeconds( rinexFirstObservationDatetime )

        offsetDatetime = datetimeEpoch - gpsReferenceDate
        offsetTotalSeconds = offsetDatetime.total_seconds()
        offsetTotalSeconds -= leap
        gpsTime.append( offsetTotalSeconds )
        gpsWNc.append( offsetTotalSeconds // weekSeconds )
        gpsTOW.append( offsetTotalSeconds % weekSeconds )

    return( gpsTime, gpsTOW, gpsWNc )


if __name__ == "__main__":
    # 1 READ FILE
    fPath = check( sys.argv )
    headerData = header( fPath )

    # 2 PRE LOAD EPOCHS
    rinexN, rinexEpochsDatetime, SVs, multiChannelTracking = getEpochs( fPath )

    # 3 CRETE COMMON TIMESCALE
    entryDeltaSeconds = calcRelativeTimesdeltas( rinexEpochsDatetime )
    rate = checkRinexRate(headerData, entryDeltaSeconds)
##    offsetTotalSeconds, offsetWNc, offsetTOW, leap = calcTimeOffsetToGPS( headerData['INFO']['TIME OF FIRST OBS']['timeSystem'] , rinexEpochsDatetime[0] )
##    gpsseconds = offsetTotalSeconds + relativeEpochs
    gpsTime, gpsTOW, gpsWNc = datetimeToGpsTime( rinexEpochsDatetime, headerData['INFO']['TIME OF FIRST OBS']['timeSystem'] )

    ## Find intermediate epochs for which no data is present
    integerTimeStep = np.round(np.diff(np.array(gpsTOW)),0)
    indicesSkippedEpoch = np.where(integerTimeStep > 1)

    ## Remove number of epochs for which no observations are present from total number of epochs
    numberSkippedEpoch = 0
    N = len(rinexEpochsDatetime)
    if indicesSkippedEpoch[0].size != 0:

        for skip in indicesSkippedEpoch[0]:
            numberSkippedEpoch += (integerTimeStep[int(skip)] - 1)                   

    print("RINEX Epochs statistics:")
    print("\tFirst:\t%s (%s) [TOW: %.2f, WNc: %i (GPS)]" % (rinexEpochsDatetime[0], headerData['INFO']['TIME OF FIRST OBS']['timeSystem'], gpsTOW[0], gpsWNc[0]) )
    print("\tLast:\t%s (%s) [TOW: %.2f, WNc: %i (GPS)]" % (rinexEpochsDatetime[-1], headerData['INFO']['TIME OF FIRST OBS']['timeSystem'], gpsTOW[-1], gpsWNc[-1]) )
##    print("\tTracking %d out of %d ( %.2f %% )" % ( N , N + numberSkippedEpoch, float(N)*100/(N + numberSkippedEpoch) ) )
    print("\tNumber of empty epochs detected (assuming 1 sec epochs): %i" % (numberSkippedEpoch) )

    sys_res = constructObsRecordRe( headerData['SYS']['OBS_TYPES'] )

    #obsRecordIdx = np.round( relativeEpochs*rate ).astype(int)
    #obsRecordIdx = np.round( np.cumsum(entryDeltaSeconds)*rate ).astype(int)
    
    # Initialize Variables
    obsRecordIdx = np.arange(0,len(gpsTime))    # Observables are stored for every epoch associated with a timestamp
    obsRecordCount = 0
    epochSvs = 0
    locationError = 0
    multiChRecord = False
    obsClasses = ["OBS", "SSI", "LLI" ]
    RINEX = {}
    
    with open( fPath ) as fh:
        for line in fh:
            m = re_obs_sv.match(line)
            if not m:
                if line[0] == ">":
                    timeScaleIdx = obsRecordIdx[ obsRecordCount ]

                    obsRecordCount += 1            

                continue
            ssn = m.group(0)
            if ssn not in SVs:
                continue
            sys_re = sys_res[ ssn[0] ]
            m_obs = sys_re.match(line)
            if not m_obs:
                print("Missed Record-->"+line)
                continue

            obsFields = m_obs.groupdict()
            # LEVEL SV
            sv = obsFields['SSN'].replace(" ", "0")
            sys = sv[0]
            if sv not in RINEX:
                RINEX[sv] = {}
            # LEVEL CH
            if sv in multiChannelTracking:
                if "X1OBS" not in obsFields:
                    raise Exception("SVs %s were tracked on several channels (concurrently in same epochs) but no CH number observation (X1) is available in RINEX file." \
                         % (multiChannelTracking))
                ch = "CH%04d" % float(obsFields["X1OBS"])
                multiChRecord = True
            else:
                ch = "CH"
                multiChRecord = False
            if ch not in RINEX[sv]:
                RINEX[sv][ch] = {}
            # LEVEL Obs
            for obsId in obsFields:#obsTypes[sys]:
                obsClass = obsId[-3:]
                if obsClass not in obsClasses:
                    continue
                obsIdRinex = obsId
                if obsClass == "OBS":
                    obsIdRinex = obsId[:-3]
#                    if obsIdRinex == "X1" and multiChRecord:
#                        continue
                if obsIdRinex not in RINEX[sv][ch]:
                    RINEX[sv][ch][obsIdRinex] = np.empty(N)
                    RINEX[sv][ch][obsIdRinex][:] = np.NaN
#                print(rinexEpochsDatetime[obsRecordCount],sv, ch, obsIdRinex, ">",obsFields[obsId],"<")
                fieldValue = obsFields[obsId] or ""
                fieldValue = float(fieldValue.strip() or np.NaN)
                # catch SX3 specific empty data representations
                if (fieldValue == 0.0) or (fieldValue == -100):
                    fieldValue = np.NaN
                # Store observation in CDS Field
                RINEX[sv][ch][obsIdRinex][timeScaleIdx] = fieldValue
                              
    RINEX['timescale'] = gpsTime
    RINEX['gpsTOW'] = gpsTOW
    RINEX['gpsWNc'] = gpsWNc
    RINEX['testing'] = obsRecordIdx
	
    io.savemat(  fPath+".mat", RINEX)



