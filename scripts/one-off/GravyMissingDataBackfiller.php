<?php

if ($argc < 3) {
  echo "Usage: php GravyMissingDataBackfiller.php <input.csv> <output.csv> [limit]\n";
  exit(1);
}

$inputFile = $argv[1];
$outputFile = $argv[2];

// Convert third argument to our limit and default to 1 if none provided.
$limit = isset($argv[3]) ? (int) $argv[3] : 1;

// Open input and output files
$inHandle = fopen($inputFile, 'rb');
if (!$inHandle) {
  fwrite(STDERR, "Error: Cannot open input file $inputFile\n");
  exit(1);
}

$outHandle = fopen($outputFile, 'wb');
if (!$outHandle) {
  fwrite(STDERR, "Error: Cannot open/create output file $outputFile\n");
  fclose($inHandle);
  exit(1);
}

// Read header row from input file
$header = fgetcsv($inHandle);
if (!$header) {
  fwrite(STDERR, "Error: Input file appears to be empty.\n");
  fclose($inHandle);
  fclose($outHandle);
  exit(1);
}

// Write the header out to the new output file
fputcsv($outHandle, $header);

$rowCount = 0;
// Read and process each row
while (($row = fgetcsv($inHandle)) !== FALSE) {
  // Stop if we've reached the limit
  if ($rowCount === $limit) {
    break;
  }

  // Extract the transaction ID
  $transactionId = NULL;
  if (isset($row[6])) {
    $transactionId = trim($row[6]);
  }

  if (empty($transactionId)) {
    // If there's no transaction ID, write the input row to the output file unchanged
    fputcsv($outHandle, $row);
    continue;
  }

  // Make API call to local URL
  $url = "http://localhost:9012/result.php?gr4vy_transaction_id={$transactionId}";
  $response = @file_get_contents($url);

  if ($response !== FALSE) {

    // Attempt to extract data regex from a print_r style output
    $backendProcessorNamePattern = '/\[payment_service\].*?\[display_name\]\s*=>\s*([^\r\n]+)/s';
    if (preg_match($backendProcessorNamePattern, $response, $matches)) {
      $displayName = strtolower(trim($matches[1]));
      $row[8] = $displayName;
    }

    $paymentServiceTransactionIdPattern = '/\[payment_service_transaction_id]\s*=>\s*([^\s]+)/';
    if (preg_match($paymentServiceTransactionIdPattern, $response, $matches)) {
      $backendProcessorTxnId = $matches[1];
      $row[9] = $backendProcessorTxnId;
    }

    $reconciliationIdPattern = '/\[reconciliation_id]\s*=>\s*([^\s]+)/';
    if (preg_match($reconciliationIdPattern, $response, $matches)) {
      $reconciliationId = $matches[1];
      $row[10] = $reconciliationId;
    }
  }

  // Write updated row to output file
  fputcsv($outHandle, $row);
  $rowCount++;
}

// Cleanup
fclose($inHandle);
fclose($outHandle);

echo "Done! updated $rowCount row(s) to '$outputFile'\n";
