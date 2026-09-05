#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# RENDER THE PUBLIC HTML DATA DICTIONARY
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# The Markdown file is authoritative. This script creates its public HTML
# companion without duplicating or manually maintaining its content.
input_file <- "raw_data/data_dictionary.md"
output_file <- "raw_data/data_dictionary.html"

if (!file.exists(input_file)) {
  stop("Missing data dictionary: ", input_file)
}

markdown <- paste(
  readLines(input_file, warn = FALSE, encoding = "UTF-8"),
  collapse = "\n"
)

html_body <- commonmark::markdown_html(
  markdown,
  extensions = c("table", "strikethrough", "autolink")
)

html_document <- paste0(
  "<!doctype html>\n",
  "<html lang=\"en\">\n<head>\n<meta charset=\"utf-8\">\n",
  "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">\n",
  "<title>Health and Defence Spending: Data Dictionary</title>\n",
  "<style>",
  "body{font-family:system-ui,sans-serif;line-height:1.6;max-width:1100px;",
  "margin:2rem auto;padding:0 1rem;color:#1f2328}",
  "table{border-collapse:collapse;width:100%;margin:1rem 0}",
  "th,td{border:1px solid #d0d7de;padding:.45rem;text-align:left;",
  "vertical-align:top}th{background:#f6f8fa}",
  "code{background:#f6f8fa;padding:.1rem .25rem}",
  "pre{overflow:auto;background:#f6f8fa;padding:1rem}",
  "</style>\n</head>\n<body>\n",
  html_body,
  "\n</body>\n</html>"
)

writeChar(html_document, output_file, eos = NULL, useBytes = TRUE)
cat("Saved ", output_file, " from ", input_file, ".\n", sep = "")
