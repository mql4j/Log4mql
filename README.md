# log4mql
Log4mql is a mql4 (MetaQuotes MetaTrader 4 Language) library for flexible logging to files and the terminal console. It is modeled after the Log4j Java library.

# Usage in your code
<pre><code>
CLog4mql::getInstance().error(\_\_FILE\_\_, \_\_LINE\_\_, "Something unexpected happen");

  or (for more frequent usage)

CLog4mql* logger = CLog4mql::getInstance();
logger.error(\_\_FILE\_\_, \_\_LINE\_\_, "Something unexpected happen");
logger.info(\_\_FILE\_\_, \_\_LINE\_\_, "Calcumation done");
logger.debug(\_\_FILE\_\_, \_\_LINE\_\_, StringFormat("The result of %s is %d", string1, value1));
</code></pre>

Dont forget at the end of your EA / Indicator / Script:
<pre><code>
CLog4mql::release();

  or

logger.release();
</code></pre>

You can configure the required log level for output in the configfile for each appending file and / or a global default.

# Log Levels:
TRACE
DEBUG
INFO
WARN
ERROR
CRIT
