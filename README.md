# log4mql
Log4mql is a mql4 (MetaQuotes MetaTrader 4 Language) library for flexible logging to files and the terminal console. It is modeled after the Log4j Java library.

## Usage in your code
<pre><code>
CLog4mql::getInstance().error(__FILE__, __LINE__, "Something unexpected happen");

  or (for more frequent usage)

CLog4mql* logger = CLog4mql::getInstance();
logger.error(__FILE__, __LINE__, "Something unexpected happen");
logger.info(__FILE__, __LINE__, "Calcumation done");
logger.debug(__FILE__, __LINE__, StringFormat("The result of %s is %d", string1, value1));
</code></pre>

Dont forget at the end of your EA / Indicator / Script:
<pre><code>
CLog4mql::release();

  or

logger.release();
</code></pre>

## Filename
You can set dynamically the file name of log with:
<pre><code>
const string typeLog=(IsDemo()?"demo":"real";
logger.setConfLogFile(StringFormat("log4mql-%s-%s.log",typeLog,Symbol()));
</code></pre>

## Directories
The directory for the log4mql.conf and the log4mql.log files
 * Normal mode: `<mt4-data-dir>/MQL4/Files/`
 * Test mode: `<mt4-data-dir>/tester/files/`

## Log Levels
You can configure the required log level for output in the configfile for each appending file and / or a global default.
 * TRACE
 * DEBUG
 * INFO
 * WARN
 * ERROR
 * CRIT
