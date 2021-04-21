// import csv from 'csv-parser';
// import * as fs from 'fs';
const csv = require('csv-parser');
const fs = require('fs');
const converter = require('json-2-csv');

interface ZipCode {
    numParks: number;
    code: number;
    meanHouseholdIncome: number | string;
    totalPopulation?: number;
    race?: RaceBreakdown;
    populationDensity?: number;
}

interface RaceBreakdown {
    [key: string]: any | string | number;
    white: string | number;
    black: string | number;
    americanIndianOrAlaskanNative: string | number;
    asian: string | number;
    nativeHawaiianOrPacificIslander: string | number;
    otherRace: string | number;
    twoOrMore: string | number;
}

let econColumnNames = {
    meanHouseholdIncome: "S1901_C01_013E",
    zipCode: "NAME"
},
    parkColumnNames = {
        zipCode: "Park_Zip"
    },
    populationColumnNames = {
        zipCode: "NAME",
        totalPopulation: "S0101_C01_001E"
    },
    raceColumnNames = {
        zipCode: "NAME",
        white: "B02001_002E",
        black: "B02001_003E",
        americanIndianOrAlaskanNative: "B02001_004E",
        asian: "B02001_005E",
        nativeHawaiianOrPacificIslander: "B02001_006E",
        otherRace: "B02001_007E",
        twoOrMore: "B02001_008E"
    },
    populationDensityColumnNames = {
        zipCode: "Zip/ZCTA",
        density: "Density Per Sq Mile"
    }


const readData = (fileName: string): Promise<any[]> => {
    let allData: any[] = [];
    let readStream = fs.createReadStream(fileName)
        .pipe(csv())
        .on('data', (data: any) => {
            allData.push(data);
        });

    return new Promise((resolve, reject) => {
        readStream.on('end', () => resolve(allData));
    });
}

(async () => {
    let economicData = await readData("./econ-data/good-data/data.csv");
    let parkData = await readData("./parks-data/parks.csv");
    let populationData = await readData("./population-data/data.csv");
    let raceData = await readData("./race-data/data.csv");
    let populationDensityData = await readData("./population-density-data/data.csv");
    // let zipCodes: ZipCode[] = [];
    let zipCodes: ZipCode[] = [];
    economicData.forEach(line => {
        var code = parseInt(line[econColumnNames.zipCode].split(" ")[1]);
        zipCodes.push({
            numParks: 0,
            code,
            meanHouseholdIncome: line[econColumnNames.meanHouseholdIncome]
        });
    });
    
    parkData.forEach(line => {
        let parkZip = parseInt(line[parkColumnNames.zipCode]);
        
        let zc = zipCodes.find(z => z.code == parkZip);
        if (zc) {
            zc.numParks ++;
        }
    });

    populationData.forEach(line => {
        var code = parseInt(line[populationColumnNames.zipCode].split(" ")[1]);
        let zc = zipCodes.find(z => z.code == code)
        if (zc) {
            zc.totalPopulation = parseInt(line[populationColumnNames.totalPopulation])
        }
    });

    populationDensityData.forEach(line => {
        let code = parseInt(line[populationDensityColumnNames.zipCode]);
        let zc = zipCodes.find(z => z.code == code);
        if (zc) {
            zc.populationDensity = parseFloat(line[populationDensityColumnNames.density]);
        }
    });

    raceData.forEach(line => {
        let code = parseInt(line[raceColumnNames.zipCode].split(" ")[1]);
        let zc = zipCodes.find(z => z.code == code);

        if (zc) {
            let raceBreakdown: RaceBreakdown = {
                white: 0,
                black: 0,
                americanIndianOrAlaskanNative: 0,
                asian: 0,
                nativeHawaiianOrPacificIslander: 0,
                otherRace: 0,
                twoOrMore: 0
            };
            Object.keys(raceColumnNames).forEach(key => {
                if (key == "code" || key == "zipCode") return;
                let rcn = raceColumnNames as RaceBreakdown;
                let columnName = rcn[key];
                raceBreakdown[key] = line[columnName];
            })
            zc.race = raceBreakdown;
        }
    });

    zipCodes.forEach(zipCode => {
        if (zipCode.meanHouseholdIncome == "-" || zipCode.meanHouseholdIncome == "N") zipCode.meanHouseholdIncome = "NA";
    });
    
    converter.json2csv(zipCodes, (err: any, data: any) => {
        fs.writeFile("merged.csv", data, {}, () => {
            console.log("Merged Data!");
        });
    });
    // console.log(economicData[0]);
})();