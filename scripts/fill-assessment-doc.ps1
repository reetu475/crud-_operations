param(
  [Parameter(Mandatory = $true)]
  [string]$DocxPath
)

Add-Type -AssemblyName System.IO.Compression.FileSystem
Add-Type -AssemblyName System.IO.Compression

$docxParent = Split-Path -Parent $DocxPath
if (-not (Test-Path -LiteralPath $docxParent)) {
  New-Item -ItemType Directory -Path $docxParent -Force | Out-Null
}

if (-not (Test-Path -LiteralPath $DocxPath)) {
  $resolvedNewPath = [System.IO.Path]::GetFullPath($DocxPath)
  $zip = [System.IO.Compression.ZipFile]::Open($resolvedNewPath, [System.IO.Compression.ZipArchiveMode]::Create)
  try {
    $contentTypes = $zip.CreateEntry("[Content_Types].xml")
    $writer = [System.IO.StreamWriter]::new($contentTypes.Open())
    $writer.Write('<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types"><Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/><Default Extension="xml" ContentType="application/xml"/><Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/></Types>')
    $writer.Close()

    $rels = $zip.CreateEntry("_rels/.rels")
    $writer = [System.IO.StreamWriter]::new($rels.Open())
    $writer.Write('<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/></Relationships>')
    $writer.Close()

    $document = $zip.CreateEntry("word/document.xml")
    $writer = [System.IO.StreamWriter]::new($document.Open())
    $writer.Write('<?xml version="1.0" encoding="UTF-8" standalone="yes"?><w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"><w:body><w:p/></w:body></w:document>')
    $writer.Close()
  }
  finally {
    $zip.Dispose()
  }
}

$resolvedPath = (Resolve-Path -LiteralPath $DocxPath).Path
$backupPath = [System.IO.Path]::ChangeExtension($resolvedPath, ".backup.docx")
Copy-Item -LiteralPath $resolvedPath -Destination $backupPath -Force

function New-ContentItem([string]$Style, [string]$Text) {
  return [PSCustomObject]@{ Kind = "Paragraph"; Style = $Style; Text = $Text }
}

function New-TableItem($Rows) {
  return [PSCustomObject]@{ Kind = "Table"; Rows = $Rows }
}

$promptRows = @(
  @("Prompt #", "Exact Prompt Text Used", "Status", "Action Taken / Changes Made"),
  @("01", "Build a basic CRUD app with React frontend, Node.js backend, MongoDB, Mongoose, .env file, no API keys, validation, async/await, and error handling.", "Modified", "Generated the initial MERN structure, then corrected the client build script."),
  @("02", "Fix concurrently not recognized.", "Accepted", "Installed root dependencies with npm install so npm run dev could find concurrently."),
  @("03", "Fix port 5000 already in use.", "Modified", "Identified and stopped an old Node process that was occupying port 5000."),
  @("04", "Firefox cannot connect to localhost:5174.", "Modified", "Discovered frontend was actually running on 5173 and restarted backend separately."),
  @("05", "Fix white screen.", "Modified", "Found old backend process serving JSON on frontend port, stopped it, and verified Vite served React HTML."),
  @("06", "White screen still appears.", "Modified", "Found runtime crash caused by missing React default import. Fixed App.jsx."),
  @("07", "Explain where created items appear.", "Accepted", "Explained that items appear in the UI, API endpoint, and MongoDB items collection."),
  @("08", "MongoDB database named crud operations.", "Modified", "Changed database name to crud_operations because spaces caused namespace issues locally."),
  @("09", "Check MongoDB URL.", "Modified", "Safely inspected only the URL scheme, host, and database name without exposing credentials."),
  @("10", "How to read items.", "Accepted", "Explained the app UI, /api/items, and MongoDB collection view."),
  @("11", "Print items for user like read.", "Accepted", "Added a visible Read Items button that fetches and displays saved items."),
  @("12", "Edit assessment template for my app.", "Accepted", "Filled the assessment document with project metrics, prompt log, evidence notes, code artifacts, and conclusions.")
)

$content = @(
  (New-ContentItem "Title" "GenAI Project Assessment: Prompt & Metrics Report"),
  (New-ContentItem "Normal" "Student Name: [Your Name]"),
  (New-ContentItem "Normal" "Date: 18 May 2026"),
  (New-ContentItem "Normal" "Project Chosen: MERN CRUD Items Application"),
  (New-ContentItem "Normal" "AI Assistant Used: Codex / ChatGPT"),
  (New-ContentItem "Heading1" "1. Executive Summary & Final Metrics"),
  (New-ContentItem "Normal" "This project is a basic full-stack CRUD application. The frontend is built with React and Vite, the backend uses Node.js and Express, and MongoDB is connected through Mongoose. Users can create, read, update, and delete item records. The UI updates after successful operations, empty titles are blocked, and errors are handled on both frontend and backend."),
  (New-ContentItem "Normal" "Total Prompts Issued: 12"),
  (New-ContentItem "Normal" "Prompts Yielding Functional Code (No edits needed): 7"),
  (New-ContentItem "Normal" "Total Lines of Code (LOC) in Final Project: approximately 610, excluding node_modules, dist, and lock files"),
  (New-ContentItem "Normal" "Total Lines of Code Manually Edited/Written by Human: approximately 35, mainly environment URL corrections and port/database naming fixes"),
  (New-ContentItem "Heading2" "Final Scores"),
  (New-ContentItem "Normal" "AI Accuracy Rate: 58.3% (7 functional prompts / 12 total prompts x 100)"),
  (New-ContentItem "Normal" "Human Correction Rate: 5.7% (35 manually corrected lines / 610 total project lines x 100)"),
  (New-ContentItem "Heading1" "2. Master Prompt & Modification Log"),
  (New-TableItem $promptRows),
  (New-ContentItem "Heading1" "3. Visual Evidence & Code Artifacts"),
  (New-ContentItem "Heading2" "Phase 1: Database Schema & Backend Setup"),
  (New-ContentItem "Normal" "Evidence: The backend connects to MongoDB using the MONGODB_URI value in server/.env. The API root returns { message: 'CRUD API is running' }, and GET /api/items returns item data from MongoDB. The Mongoose models are Item.js and OperationLog.js."),
  (New-ContentItem "Normal" "Backend files: server/server.js, server/src/models/Item.js, server/src/models/OperationLog.js, server/src/controllers/itemController.js, server/src/routes/itemRoutes.js."),
  (New-ContentItem "Heading2" "Code Check: AI Generation vs Human Fix"),
  (New-ContentItem "Normal" "Issue 1 - Missing React import caused a white screen."),
  (New-ContentItem "Normal" "Broken version: import { useEffect, useMemo, useState } from 'react';"),
  (New-ContentItem "Normal" "Fixed version: import React, { useEffect, useMemo, useState } from 'react';"),
  (New-ContentItem "Normal" "Issue 2 - Invalid MongoDB database namespace caused read failures."),
  (New-ContentItem "Normal" "Broken version: MONGODB_URI=mongodb://localhost:27017/crud%20operations"),
  (New-ContentItem "Normal" "Fixed version: MONGODB_URI=mongodb://localhost:27017/crud_operations"),
  (New-ContentItem "Heading2" "Phase 2: Core CRUD UI & Functionality"),
  (New-ContentItem "Normal" "The React UI contains title and description inputs, a Create button, a Read Items button, Edit and Delete actions for each saved item, loading/error/success states, and instant UI updates after successful create, update, and delete operations."),
  (New-ContentItem "Normal" "Evidence screenshot available in the project folder: frontend-check-fixed.png. It shows the Items UI rendered successfully."),
  (New-ContentItem "Heading1" "4. Conclusions & Key Takeaways"),
  (New-ContentItem "Normal" "Where did the AI assistant perform best? It performed best at quickly generating the project structure, Express routes, Mongoose models, React form, styling, and CRUD request flow."),
  (New-ContentItem "Normal" "Where did the AI struggle the most? It needed human-in-the-loop correction around local environment details: ports already in use, old Node processes, the MongoDB database name, and a React runtime import issue that caused a white screen."),
  (New-ContentItem "Normal" "What did you learn about Human-in-the-Loop development? I learned that AI can build a working foundation quickly, but the developer still needs to test, read errors, verify ports, inspect database connections, and correct environment-specific problems. The final app became reliable only after testing each part: frontend, backend, API, and MongoDB.")
)

function Escape-Xml([string]$Value) {
  return [System.Security.SecurityElement]::Escape($Value)
}

function New-ParagraphXml($Item) {
  $styleXml = ""
  if ($Item.Style -and $Item.Style -ne "Normal") {
    $styleXml = "<w:pPr><w:pStyle w:val=`"$($Item.Style)`"/></w:pPr>"
  }

  $text = Escape-Xml $Item.Text
  return "<w:p>$styleXml<w:r><w:t xml:space=`"preserve`">$text</w:t></w:r></w:p>"
}

function New-CellXml([string]$Text) {
  $escaped = Escape-Xml $Text
  return "<w:tc><w:tcPr><w:tcW w:w=`"2400`" w:type=`"dxa`"/></w:tcPr><w:p><w:r><w:t xml:space=`"preserve`">$escaped</w:t></w:r></w:p></w:tc>"
}

function New-TableXml($Rows) {
  $tablePr = "<w:tblPr><w:tblStyle w:val=`"TableGrid`"/><w:tblW w:w=`"0`" w:type=`"auto`"/><w:tblBorders><w:top w:val=`"single`" w:sz=`"4`" w:space=`"0`" w:color=`"auto`"/><w:left w:val=`"single`" w:sz=`"4`" w:space=`"0`" w:color=`"auto`"/><w:bottom w:val=`"single`" w:sz=`"4`" w:space=`"0`" w:color=`"auto`"/><w:right w:val=`"single`" w:sz=`"4`" w:space=`"0`" w:color=`"auto`"/><w:insideH w:val=`"single`" w:sz=`"4`" w:space=`"0`" w:color=`"auto`"/><w:insideV w:val=`"single`" w:sz=`"4`" w:space=`"0`" w:color=`"auto`"/></w:tblBorders></w:tblPr>"
  $rowXml = foreach ($row in $Rows) {
    $cells = ($row | ForEach-Object { New-CellXml $_ }) -join ""
    "<w:tr>$cells</w:tr>"
  }
  return "<w:tbl>$tablePr$($rowXml -join '')</w:tbl>"
}

$zip = [System.IO.Compression.ZipFile]::Open($resolvedPath, [System.IO.Compression.ZipArchiveMode]::Update)
try {
  $entry = $zip.GetEntry("word/document.xml")
  $reader = [System.IO.StreamReader]::new($entry.Open())
  $documentXml = $reader.ReadToEnd()
  $reader.Close()

  $bodyXml = ($content | ForEach-Object {
    if ($_.Kind -eq "Table") {
      New-TableXml $_.Rows
    } else {
      New-ParagraphXml $_
    }
  }) -join "`n"
  $newXml = [regex]::Replace(
    $documentXml,
    "(?s)<w:body>.*</w:body>",
    "<w:body>$bodyXml<w:sectPr><w:pgSz w:w=`"12240`" w:h=`"15840`"/><w:pgMar w:top=`"1440`" w:right=`"1440`" w:bottom=`"1440`" w:left=`"1440`" w:header=`"720`" w:footer=`"720`" w:gutter=`"0`"/></w:sectPr></w:body>"
  )

  $entry.Delete()
  $newEntry = $zip.CreateEntry("word/document.xml")
  $writer = [System.IO.StreamWriter]::new($newEntry.Open())
  $writer.Write($newXml)
  $writer.Close()
}
finally {
  $zip.Dispose()
}

Write-Output "Updated: $resolvedPath"
Write-Output "Backup:  $backupPath"
