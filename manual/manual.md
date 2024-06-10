# ABDA API usage

## Version History

| Date         | Version | Changes                                                      |
| ------------ | ------  | -------                                                      |
| 10-20-2023   | 0.1.0   | Initial document                                             |
| 11-06-2023   | 0.2.0   | Updates authorization schema (Bearer format)                 |
| 02-21-2024   | 0.3.0   | Adds PZN search endpoint, fixed documentation error          |
| 02-22-2024   | 0.4.0   | Adds /pzns/products endpoint                                 |
| 03-19-2024   | 0.5.0   | Changes /pzns/products endpoint to include ATC output        |
| 05-15-2024   | 0.6.0   | Adds potentially inadequate medicine (Priscus 2.0) endpoints |
| 05-17-2024   | 0.6.1   | Adds QTc drugs according to crediblemeds.org                 |
| 06-10-2024   | 0.6.2   | Adds ADRs for DDIs, DDI query for pzns                       |

## General Remarks
The ABDATA API has been provided by the Saarland University Clinical Pharmacy working group. The API is not intended for public use, but only for usage within the SafePolyMed project. This document is intended as a guide for using the API, it is, however, not a comprehensive manual or technical documentation of the API.
## Access
The API is provided under the following URL: [https://abdata.clinicalpharmacy.me/api](https://abdata.clinicalpharmacy.me/api).
## Usage and Testing Info
The API is generally intended for usage with dedicated console utilities such as *curl* or the corresponding utilities in programming languages such as the *httr* or similar packages in the *R* programming language.
There is no dedicated endpoint for testing access to the API yet. However, testing **GET** endpoints is possible in a browser, for instance [https://abdata.clinicalpharmacy.me/api/limits](https://abdata.clinicalpharmacy.me/api/limits) should return
```json
{
    "type": "https://tools.ietf.org/html/rfc7235#section-3.1",
    "title": "Unauthorized", 
    "status": 401, 
    "detail": "No login token provided.", 
    "instance": "/limits" 
}
```
## Authorization
This API uses *Java Web Token (jwt)* for authentication. A *jwt* is provided to you [upon login](#post-login) and must be provided when accessing all other routes. See [GET /interactions/compounds](#get-interactionscompounds)  as an example on how to provide the token.
## Endpoints
The following is a list of endpoints for the API.
All endpoints are only accessible **without a trailing slash!**
All routes refer to [https://abdata.clinicalpharmacy.me/api](https://abdata.clinicalpharmacy.me/api) as the root URI.
Currently, all access to all routes other than [POST /login](#post-login) **require authentication.**

| Group        | Method | Route                     | Reference                                                   | Description                                                                                                         |
| ------------ | ------ | ------------------------- | ----------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------- |
| user         | POST   | /login                    | [POST /login](#post-login)                                  | Log a user in.                                                                                                      |
| user         | GET    | /renew-token              |                                                             | Retrieve a new token. No parameters.                                                                                |
| information  | GET    | /formulations             |                                                             | Retrieve a list of all formulations within the database. No parameters.                                             |
| information  | GET    | /limits                   |                                                             | Request limits of the server. No parameters.                                                                        |
| information  | GET    | /interactions/description |                                                             | Request description of the interaction table. No parameters.                                                        |
| interactions | GET    | /interactions/compounds   | [GET /interactions/compounds](#get-interactionscompounds)   | Interaction endpoint for compound names input.                                                                      |
| interactions | POST   | /interactions/compounds   | [POST /interactions/compounds](#post-interactionscompounds) | Interaction endpoint for compound names input from json.                                                            |
| interactions | GET    | /interactions/pzns        | [GET /interactions/pzns](#get-interactionspzns)             | Interaction endpoint for pzn input.                                                                                 |
| interactions | POST   | /interactions/pzns        |                                                             | Interaction endpoint for pzn input from json.                                                                       |
| priscus      | GET    | /priscus/compounds        | [GET /priscus/compounds](#get-priscuscompounds)             | Priscus 2.0 (potentially inadequate medicine for geriatric patients) endpoint for compound name input.              |
| priscus      | POST   | /priscus/compounds        | [POST /priscus/compounds](#post-priscuscompounds)           | Priscus 2.0 (potentially inadequate medicine for geriatric patients) endpoint for compound name input from json.    |
| priscus      | GET    | /priscus/pzns             | [GET /priscus/pzns](#get-priscuspzns)                       | Priscus 2.0 (potentially inadequate medicine for geriatric patients) endpoint for pzn input.                        |
| priscus      | POST   | /priscus/pzns             | [POST /priscus/pzns](#post-priscuspzns)                     | Priscus 2.0 (potentially inadequate medicine for geriatric patients) endpoint for pzn input from json.              |
| qtc          | GET    | /qtc/compounds            | [GET /qtc/compounds](#get-qtccompounds)                     | QTc (drugs with risk for Torsade de pointes) endpoint for compound name input.                                      |
| qtc          | POST   | /qtc/compounds            | [POST /qtc/compounds](#post-qtccompounds)                   | QTc (drugs with risk for Torsade de pointes) endpoint for compound name input from json.                            |
| qtc          | GET    | /qtc/pzns                 |                                                             | QTc (drugs with risk for Torsade de pointes) endpoint for pzn input.                                                |
| qtc          | POST   | /qtc/pzns                 |                                                             | QTc (drugs with risk for Torsade de pointes) endpoint for pzn input from json.                                      |
| atc          | GET    | /atcs/drugs               | [GET /atcs/drugs](#get-atcsdrugs)                           | Drug endpoint for ATC input.                                                                                        |
| adrs         | GET    | /adrs/pzns                | [GET /adrs/pzns](#get-adrspzns)                             | ADR endpoint for PZN input.                                                                                         |
| adrs         | POST   | /adrs/pzns                |                                                             | ADR endpoint for PZN input.                                                                                         |
| pzns         | GET    | /pzns/products            | [GET /pzns/products](#get-pznsproducts)                     | Drug products endpoint for PZN input.                                                                               |


## Example Usage
### POST /login
#### Input
Provide your credentials as a *json*. The *json* must be structured as follows:
```json
{
    "credentials": {
        "username": "your_username",
        "password": "your_password"
    }
}
```
#### Example Usage
```curl
  curl -X POST "https://abdata.clinicalpharmacy.me/api/login"  \
    -H "accept: application/json" \
    -H "Content-Type: application/json" \
    -d '{"credentials":{"username":"username","password":"password"}}'
```
#### Output
The return value for a successful **POST** request has the following structure:
```json
{
    "yourjwttoken"
}
```
### GET /interactions/compounds
#### Input
Check for interactions based on compound names provided as query parameters. 
#### Example Usage
```curl
curl -X GET "https://abdata.clinicalpharmacy.me/api/interactions/compounds?compounds=verapamil,simvastatin" \
    -H "accept: application/json" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer yourjwttoken"
```
#### Output
The return value for a successful **GET** request has the following structure:
```json
{
  "interactions": [
    {
      "plausibility": "plausible mechanism",
      "relevance": "severe",
      "frequency": "not known",
      "credibility": "high",
      "direction": "unidirectional interaction",
      "left_compound": "Simvastatin",
      "right_compound": "Verapamil",
      "left_atc": "C10AA01",
      "right_atc": "C08DA01",
      "left_formulation": "FTA",
      "right_formulation": "FTA",
      "left_medication": "ZOCOR 10mg",
      "right_medication": "Isoptin 80mg",
      "left_dose": "10 mg",
      "right_dose": "74.06 mg"
    }
  ],
  "unknown_compounds": [],
  "timestamp": "2023-10-20 13:20:57",
  "api_version": "0.3.0",
  "compounds": [
    "verapamil",
    "simvastatin"
  ]
}
```
### POST /interactions/compounds
#### Input
Check for interactions based on compound names provided as *json*. Drug lists must be provided matched to an *ID*:
Explain is an optional parameter, if set to *true*, the API will return the explanation for the interaction.
Default is *false*.
```json
{
    [
        { 
            "id": "1",
            "compounds": ["verapamil","simvastatin"]
        },
        { 
            "id": "2",
            "compounds": ["diltiazem","amiodarone","amlodipine","lovastatin"],
            "explain": true
        }
    ]
}
```
#### Example Usage
```curl
curl -X POST "https://abdata.clinicalpharmacy.me/api/interactions/compounds" \
     -H "Authorization: Bearer yourjwttoken" \
     -H "Content-Type: application/json" \
     -d '[{"id":"1","compounds":["verapamil","simvastatin"]},{"id":"2","compounds":["diltiazem","amiodarone","amlodipine","lovastatin"],"explain":true}]'
```
#### Output
The return value for a successful **POST** request has the following structure:
```json
{
  "results": [
    {
      "interactions": [
        {
          "plausibility": "plausible mechanism",
          "relevance": "severe",
          "frequency": "not known",
          "credibility": "high",
          "direction": "unidirectional interaction",
          "left_compound": "Simvastatin",
          "right_compound": "Verapamil",
          "left_atc": "C10AA01",
          "right_atc": "C08DA01",
          "left_formulation": "FTA",
          "right_formulation": "FTA",
          "left_medication": "ZOCOR 10mg",
          "right_medication": "Isoptin 80mg",
          "left_dose": "10 mg",
          "right_dose": "74.06 mg"
        }
      ],
      "unknown_compounds": [],
      "id": "1",
      "compounds": [
        "verapamil",
        "simvastatin"
      ]
    },
    {
      "interactions": [
        {
          "plausibility": "plausible mechanism",
          "relevance": "moderate",
          "frequency": "not known",
          "credibility": "weak",
          "direction": "undirected interaction",
          "left_compound": "Amiodarone",
          "right_compound": "Diltiazem",
          "left_atc": "C01BD01",
          "right_atc": "C08DB01",
          "left_formulation": "DFL",
          "right_formulation": "RET",
          "left_medication": "Cordarex 150mg/3ml Injektionslösung",
          "right_medication": "Dilzem 120mg retard",
          "left_dose": "141.98 mg",
          "right_dose": "110.3 mg"
        },
        {
          "plausibility": "plausible mechanism",
          "relevance": "severe",
          "frequency": "not known",
          "credibility": "high",
          "direction": "unidirectional interaction",
          "left_compound": "Lovastatin",
          "right_compound": "Amiodarone",
          "left_atc": "C10AA02",
          "right_atc": "C01BD01",
          "left_formulation": "TAB",
          "right_formulation": "DFL",
          "left_medication": "Lovastatin AL 20mg",
          "right_medication": "Cordarex 150mg/3ml Injektionslösung",
          "left_dose": "20 mg",
          "right_dose": "141.98 mg"
        },
        {
          "plausibility": "plausible mechanism",
          "relevance": "severe",
          "frequency": "not known",
          "credibility": "high",
          "direction": "unidirectional interaction",
          "left_compound": "Lovastatin",
          "right_compound": "Diltiazem",
          "left_atc": "C10AA02",
          "right_atc": "C08DB01",
          "left_formulation": "TAB",
          "right_formulation": "RET",
          "left_medication": "Lovastatin AL 20mg",
          "right_medication": "Dilzem 120mg retard",
          "left_dose": "20 mg",
          "right_dose": "110.3 mg"
        },
        {
          "relevance": "no statement possible",
          "left_compound": "Lovastatin",
          "right_compound": "Amlodipine",
          "right_atc": "C08CA01",
          "right_formulation": "TAB",
          "right_medication": "Norvasc 5mg",
          "right_dose": "5 mg"
        }
      ],
      "unknown_compounds": [],
      "id": "2",
      "compounds": [
        "diltiazem",
        "amiodarone",
        "amlodipine",
        "lovastatin"
      ]
    }
  ],
  "timestamp": "2023-10-20 13:21:59",
  "api_version": "0.3.0"
}
```

### POST /interactions/pzns
#### Input
Check for interactions based on PZNs (*Pharmazentralnummer*, a German product identifier for drugs)  provided as *json*. Lists of PZNs must be provided matched to an *ID*:
```json
  [ 
      {
          "id": "1", 
          "pzns":["03041347","17145955","00592733","13981502"] 
      },
      {
          "id": "2", 
          "pzns":["03041347","17145955","00592733","13981502"] 
      }
]
        
```
#### Example Usage
```curl
curl -X POST "https://abdata.clinicalpharmacy.me/api/interactions/pzns" \
     -H "Authorization: Bearer yourjwttoken" \
     -H "Content-Type: application/json" \
     -d '[{"id":"1","pzns":["03041347","17145955","00592733","13981502"]},{"id":"2","pzns":["03041347","17145955","00592733","13981502"]}]'
```
#### Output
The return value for a successful **POST** request has the following structure:
```json
{
  "results": [
    {
      "interactions": [
        {
          "plausibility": "plausible mechanism",
          "relevance": "minor",
          "frequency": "not known",
          "credibility": "weak",
          "direction": "unidirectional interaction",
          "left_PZN": "03041347",
          "right_PZN": "00592733"
        }
      ],
      "unknown_pzns": [],
      "id": "1",
      "pzns": [
        "03041347",
        "17145955",
        "00592733",
        "13981502"
      ]
    },
    {
      "interactions": [
        {
          "plausibility": "plausible mechanism",
          "relevance": "minor",
          "frequency": "not known",
          "credibility": "weak",
          "direction": "unidirectional interaction",
          "left_PZN": "03041347",
          "right_PZN": "00592733"
        }
      ],
      "unknown_pzns": [],
      "id": "2",
      "pzns": [
        "03041347",
        "17145955",
        "00592733",
        "13981502"
      ]
    }
  ],
  "timestamp": "2023-10-20 13:17:41",
  "api_version": "0.3.0"
}
```
### GET /priscus/compounds
#### Input
Check for potentially inadequate medication for geriatric patients (Priscus 2.0) based on compound names provided as query parameters. 
#### Example Usage
```curl
curl -X GET "https://abdata.clinicalpharmacy.me/api/priscus/compounds?compounds=metoprolol,pindolol,diazepam" \
    -H "accept: application/json" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer yourjwttoken"
```
#### Output
The return value for a successful **GET** request has the following structure:
```json
{
  "priscus": [
    {
      "compound": "Metoprolol",
      "priscus": false
    },
    {
      "compound": "Pindolol",
      "priscus": true
    },
    {
      "compound": "Diazepam",
      "priscus": true
    }
  ],
  "unknown_compounds": [],
  "timestamp": "2024-05-16 12:31:53",
  "api_version": "0.6.0",
  "compounds": ["metoprolol", "pindolol", "diazepam"]
}
```

### POST /priscus/compounds
#### Input
Check for potentially inadequate medication for geriatric patients (Priscus 2.0) based on compound names provided as *json*.
Drug lists must be provided matched to an *ID*:
```json
{
    [
        { 
            "id": "1",
            "compounds": ["metoprolol","pindolol"] 
        },
        { 
            "id": "2",
            "compounds": ["diazepam","ranitidine","amlodipine","lovastatin"] 
        }
    ]
}
```

#### Example Usage
```curl
curl -X POST "https://abdata.clinicalpharmacy.me/api/priscus/compounds" \
     -H "Authorization: Bearer yourjwttoken" \
     -H "Content-Type: application/json" \
     -d '[{"id":"1","compounds":["metoprolol","pindolol","diazepam"]},{"id":"2","compounds":["diazepam","ranitidine","amlodipine","lovastatin"]}]'
```
#### Output
The return value for a successful **POST** request has the following structure:
```json
{
  "results": [
    {
      "priscus": [
        {
          "compound": "Metoprolol",
          "priscus": false
        },
        {
          "compound": "Pindolol",
          "priscus": true
        },
        {
          "compound": "Diazepam",
          "priscus": true
        }
      ],
      "unknown_compounds": [],
      "id": "1",
      "compounds": ["metoprolol", "pindolol", "diazepam"]
    },
    {
      "priscus": [
        {
          "compound": "Diazepam",
          "priscus": true
        },
        {
          "compound": "Ranitidine",
          "priscus": true
        },
        {
          "compound": "Amlodipine",
          "priscus": false
        },
        {
          "compound": "Lovastatin",
          "priscus": false
        }
      ],
      "unknown_compounds": [],
      "id": "2",
      "compounds": ["diazepam", "ranitidine", "amlodipine", "lovastatin"]
    }
  ],
  "timestamp": "2024-05-16 12:58:51",
  "api_version": "0.6.0"
}
```
### GET /priscus/pzns
#### Input
Check for potentially inadequate medicine for geriatric patients based on PZNs (*Pharmazentralnummer*, a German product identifier for drugs) provided as *query parameters*.

#### Example Usage
```curl
curl -X POST "https://abdata.clinicalpharmacy.me/api/priscus/pzns?pzns=03967062,03041347,00592733" \
     -H "Authorization: Bearer yourjwttoken" \
     -H "Content-Type: application/json" \
```
#### Output
The return value for a successful **GET** request has the following structure:
```json
{
  "priscus": [
    {
      "pzn": "00592733",
      "priscus": false
    },
    {
      "pzn": "03041347",
      "priscus": true
    },
    {
      "pzn": "03967062",
      "priscus": true
    }
  ],
  "unknown_pzns": [],
  "timestamp": "2024-05-16 13:13:05",
  "api_version": "0.6.0",
  "pzns": ["03967062", "03041347", "00592733"]
}
```

### POST /priscus/pzns
#### Input
Check for potentially inadequate medicine for geriatric patients based on PZNs (*Pharmazentralnummer*, a German product identifier for drugs) provided as *json*.
Lists of PZNs must be provided matched to an *ID*:
```json
[ 
  {
    "id": "1", 
    "pzns":["03041347","17145955","00592733","13981502"] 
  },
  {
    "id": "2", 
    "pzns":["03041347","17145955","00592733","13981502"] 
  }
]
```
#### Example Usage
```curl
curl -X POST "https://abdata.clinicalpharmacy.me/api/priscus/pzns" \
     -H "Authorization: Bearer yourjwttoken" \
     -H "Content-Type: application/json" \
     -d '[{"id":"1","pzns":["03041347","17145955","00592733","13981502"]},{"id":"2","pzns":["03041347","17145955","00592733","13981502"]}]'
```
#### Output
The return value for a successful **POST** request has the following structure:
```json
{
  "results": [
    {
      "priscus": [
        {
          "pzn": "00592733",
          "priscus": false
        },
        {
          "pzn": "03041347",
          "priscus": true
        },
        {
          "pzn": "13981502",
          "priscus": false
        },
        {
          "pzn": "17145955",
          "priscus": false
        }
      ],
      "unknown_pzns": [],
      "id": "1",
      "pzns": ["03041347", "17145955", "00592733", "13981502"]
    },
    {
      "priscus": [
        {
          "pzn": "00592733",
          "priscus": false
        },
        {
          "pzn": "03041347",
          "priscus": true
        },
        {
          "pzn": "13981502",
          "priscus": false
        },
        {
          "pzn": "17145955",
          "priscus": false
        }
      ],
      "unknown_pzns": [],
      "id": "2",
      "pzns": ["03041347", "17145955", "00592733", "13981502"]
    }
  ],
  "timestamp": "2024-05-16 12:58:51",
  "api_version": "0.6.0"
}
```

### GET /qtc/compounds
#### Input
Check for drugs with risks for Torsade de pointes according to [crediblemeds.org](https://crediblemeds.org) based on compound names provided as query parameters. 
The following categories are used:

- 0: Unknown risk
- 1: Conditional risk
- 2: Possible risk
- 3: Known risk


#### Example Usage
```curl
curl -X GET "https://abdata.clinicalpharmacy.me/api/qtc/compounds?compounds=quinidine,diphenhydramine,ciprofloxacine" \
    -H "accept: application/json" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer yourjwttoken"
```
#### Output
The return value for a successful **GET** request has the following structure:
```json
{
  "qtc": [
    {
      "Name": "Diphenhydramine",
      "qtc_category": 1,
      "description": "Conditional risk for Torsade de pointes according to crediblemeds.org"
    },
    {
      "Name": "Quinidine",
      "qtc_category": 3,
      "description": "Known risk for Torsade de pointes according to crediblemeds.org"
    },
    {
      "Name": "Ciprofloxacine",
      "qtc_category": 3,
      "description": "Known risk for Torsade de pointes according to crediblemeds.org"
    }
  ],
  "unknown_compounds": [],
  "timestamp": "2024-05-17 08:58:27",
  "api_version": "0.6.0",
  "compounds": ["quinidine", "diphenhydramine", "ciprofloxacine"]
}
```

### POST /qtc/compounds
#### Input
Check for drugs with risks for Torsade de pointes according to [crediblemeds.org](https://crediblemeds.org) based on compound names provided as query parameters. 
The following categories are used:
- 0: Unknown risk
- 1: Conditional risk
- 2: Possible risk
- 3: Known risk

Drug lists must be provided matched to an *ID*:

```json
{
  [
    { 
      "id": "1",
      "compounds": ["verapamil", "simvastatin", "diltiazem", "amiodarone", "amlodipine", "lovastatin"]
    }
  ]
}
```

#### Example Usage
```curl
curl -X POST "https://abdata.clinicalpharmacy.me/api/qtc/compounds" \
     -H "Authorization: Bearer yourjwttoken" \
     -H "Content-Type: application/json" \
     -d '[{"id":"1","compounds":["verapamil", "simvastatin", "diltiazem", "amiodarone", "amlodipine", "lovastatin"]}]'
```
#### Output
The return value for a successful **POST** request has the following structure:
```json
{
  "results": [
    {
      "qtc": [
        {
          "Name": "Amiodarone",
          "qtc_category": 3,
          "description": "Known risk for Torsade de pointes according to crediblemeds.org"
        },
        {
          "Name": "Diltiazem",
          "qtc_category": 1,
          "description": "Conditional risk for Torsade de pointes according to crediblemeds.org"
        },
        {
          "Name": "Verapamil",
          "qtc_category": 0,
          "description": "Risk unknown"
        },
        {
          "Name": "Amlodipine",
          "qtc_category": 0,
          "description": "Risk unknown"
        },
        {
          "Name": "Lovastatin",
          "qtc_category": 0,
          "description": "Risk unknown"
        },
        {
          "Name": "Simvastatin",
          "qtc_category": 0,
          "description": "Risk unknown"
        }
      ],
      "unknown_compounds": [],
      "id": "1",
      "compounds": ["verapamil", "simvastatin", "diltiazem", "amiodarone", "amlodipine", "lovastatin"]
    }
  ],
  "timestamp": "2024-05-17 09:00:08",
  "api_version": "0.6.0"
}
```

### GET /atcs/drugs
#### Input
Get drug names based on ATCs. Please note, that some ATCs may not resolve to a unique drug product, especially in case of fixed drug combinations
#### Example Usage
```curl
curl -X GET "https://abdata.clinicalpharmacy.me/api/atcs/drugs?atcs=C01BD01,C08DB01,C08DA01,J01CR02" \
    -H "accept: */*" \
    -H "Authorization: Bearer yourjwttoken"
```
#### Output
The return value for a successful **GET** request has the following structure:
```json
{ 
    "names": [ 
        { 
            "atc": "C01BD01", 
            "name_german":"Amiodaron", 
            "name_english":"Amiodarone" 
        }, 
        { 
            "atc": "C08DA01" 
            ,"name_german": "Verapamil",
            "name_english":"Verapamil"
        },
        { 
            "atc": "C08DB01", 
            "name_german": "Diltiazem",
            "name_english": "Diltiazem"
        }, 
        { 
            "atc": "J01CR02", 
            "name_german": "Amoxicillin und Beta-Lactamase-Inhibitor", 
            "name_english":"Amoxicillin and beta-lactamase inhibitor"
        }
    ],
    "unknown_atcs":[],
    "timestamp": "2023-10-20 10:56:21",
    "api_version": "0.3.0", 
    "atcs": ["C01BD01","C08DB01","C08DA01","J01CR02"]
} 
```
### GET /adrs/pzns
#### Input
Get ADRs for PZNs. Please note, that some PZNs may not be up to date.
#### Example Usage
```curl
curl -X GET "https://abdata.clinicalpharmacy.me/api/adrs/pzns?pzns=03967062,03041347,00592733" \
    -H "accept: */*" \
    -H "Authorization: Bearer yourjwttoken"
```
#### Output
The return value for a successful **GET** request has the following structure:
```json
{
  "lang": "english",
  "results": [
    {
      "pzn": "00592733",
      "adrs": [
        {
          "adr_frequency_category": 5,
          "adr_frequency_description": "Very rare (< 0.01%)",
          "names": "epilepsy"
        },
        {
          "adr_frequency_category": 5,
          "adr_frequency_description": "Very rare (< 0.01%)",
          "names": ["thrombocytopenia", "thrombopenia"]
        }
      ]
    },
    {
      "pzn": "03041347",
      "adrs": [
        {
          "adr_frequency_category": 6,
          "adr_frequency_description": "Unknown",
          "names": "torsade de pointes"
        },
        {
          "adr_frequency_category": 4,
          "adr_frequency_description": "Rare (>= 0.01% to < 0.1%)",
          "names": ["amenorrhoea", "amenorrhea post pill", "lack of menses"]
        }
      ]
    },
    {
      "pzn": "03967062",
      "adrs": [
        {
          "adr_frequency_category": 3,
          "adr_frequency_description": "Occasional (>= 0.1% to < 1%)",
          "names": ["bradycardia", "reflex bradycardia"]
        },
        {
          "adr_frequency_category": 2,
          "adr_frequency_description": "Common (>= 1% to < 10%)",
          "names": ["hypotension", "arterial hypotension"]
        },
        {
          "adr_frequency_category": 6,
          "adr_frequency_description": "Unknown",
          "names": ["AV nodals block", "atrioventricular block"]
        }
      ]
    }
  ],
  "unknown_pzns": [],
  "timestamp": "2024-06-10 15:12:50",
  "api_version": "0.6.2",
  "pzns": ["03967062", "03041347", "00592733"]
}
```

### GET /pzns/products
#### Input
Get product names and ATC codes based on PZNs. Please note, that some PZNs may not be up to date.
#### Example Usage
```curl
curl -X GET "https://abdata.clinicalpharmacy.me/api/pzns/products?pzns=03967062,03041347,00592733" \
    -H "accept: */*" \
    -H "Authorization: Bearer yourjwttoken"
```
#### Output
The return value for a successful **GET** request has the following structure:
```json
{
    "products": [
    {
        "pzn":"00592733",
        "product":"Famotidin STADA 40mg",
        "atc":"A02BA03"
    },
    {
        "pzn":"03041347",
        "product":"Domperidon AbZ 10mg",
        "atc":"A03FA03"
    },
    {
        "pzn":"03967062",
        "product":"MCP-ratiopharm 10mg",
        "atc":"A03FA01"
    }
    ],
    "unknown_pzns":[],
    "timestamp":"2024-02-22 09:05:55",
    "api_version":"0.3.0",
    "pzns":[
        "03967062",
        "03041347",
        "00592733"
    ]
}
```
