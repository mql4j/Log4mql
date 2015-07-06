#ifndef __LOG4MQL__
#define __LOG4MQL__

#property copyright "GPL2 Written by Michael Schmidt (m@swayp.net)"
#property link "https://swayp.net"
#property strict

/**
 * Log4mql
 *
 * Log4mql is a mql4 (MetaQuotes MetaTrader 4 Language) library for flexible
 * logging to files and the terminal console. It is modeled after the Log4j
 * Java library.
 *
 * Usage in your code:
 * 
 * CLog4mql::getInstance().error(__FILE__, __LINE__, 
 *       "Something unexpected happen");
 * 
 *   or (for more frequent usage)
 *
 * CLog4mql* logger = CLog4mql::getInstance();
 * logger.error(__FILE__, __LINE__, "Something unexpected happen");
 * logger.info(__FILE__, __LINE__, "Calcumation done");
 * logger.debug(__FILE__, __LINE__, StringFormat("The result of %s is %d",
 *       string1, value1));
 *
 * Dont forget at the end of your EA / Indicator / Script:
 * CLog4mql::release();
 *    or
 * logger.release();
 *
 * You can configure the required log level for output in the configfile
 * For each appending file and / or a global default.
 *
 * Log Levels:
 *	TRACE
 *	DEBUG
 *	INFO
 *	WARN
 *	ERROR
 *	CRIT
 */

/**
 * Log levels
 */
#define LOG4MQL_LEVEL_TRACE					6
#define LOG4MQL_LEVEL_DEBUG					5
#define LOG4MQL_LEVEL_INFO					4
#define LOG4MQL_LEVEL_WARN					3
#define LOG4MQL_LEVEL_ERROR					2
#define LOG4MQL_LEVEL_CRIT					1

/**
 * Configuation file
 */
#define LOG4MQL_CONFFILE					"log4mql.conf"

/**
 * Default configuration
 */
#define LOG4MQL_DEFAULT_LOGFILE				"log4mql.log"
#define LOG4MQL_DEFAULT_LEVEL				4
#define LOG4MQL_DEFAULT_ROTATE_ENABLE		true
#define LOG4MQL_DEFAULT_ROTATE_CHECK_PERIOD	1000
#define LOG4MQL_DEFAULT_ROTATE_SIZE_MB		1
#define LOG4MQL_DEFAULT_ROTATE_GENERATIONS	8

/**
 * Class CLog4mql
 *
 * Dynamic logger designed to provide log4j style logging to mql4
 */
class CLog4mql {
private:
	static CLog4mql *instance;
	string confLogFile;
	int confDefaultLevel;
	bool confRotateEnabled;
	int confRotateCheckPeriod;
	ulong confRotateSize;
	int confRotateGenerations;
	int logFileHandle;
	int configs;
	string configFile[100];
	int configLevel[100];
	int actionsLastRotate;

protected:
	/**
	 * Constructor
	 */
	CLog4mql() {
		confLogFile = LOG4MQL_DEFAULT_LOGFILE;
		confDefaultLevel = LOG4MQL_DEFAULT_LEVEL;
		confRotateEnabled = LOG4MQL_DEFAULT_ROTATE_ENABLE;
		confRotateCheckPeriod = LOG4MQL_DEFAULT_ROTATE_CHECK_PERIOD;
		confRotateSize = LOG4MQL_DEFAULT_ROTATE_SIZE_MB * 1024 * 1024;
		confRotateGenerations = LOG4MQL_DEFAULT_ROTATE_GENERATIONS;
		logFileHandle = INVALID_HANDLE;
		configs = 0;
		loadConfig();
		actionsLastRotate = confRotateCheckPeriod;
	}

	/**
	 * Destructor
	 */
	~CLog4mql() {
		closeLogFile();
	}

private:
	/**
	 * Prevent copy of singleton instance
	 */
	CLog4mql(const CLog4mql&);

public:
	/**
	 * GetInstance
	 * 
	 * Get singleton instance
	 */
	static CLog4mql * getInstance() {
		if(instance == NULL) {
			instance = new CLog4mql();
			instance.debug(__FILE__, __LINE__, "Instance created");
		}
 		return instance;
	}

	/**
	 * Release
	 * 
	 * Release singleton instance
	 */
	static void release() {
		if(instance != NULL) {
			instance.debug(__FILE__, __LINE__, "Instance released");
			delete instance;
		}
		instance = NULL;
	}

public:
	/**
	 * Trace
	 *
	 * Log trace message
	 *
	 * @var string file
	 *		Origin file name which sends the log message (__FILE__)
	 * @var int line
	 *		Line of log method call in origin file (__LINE__)
	 * @var string msg
	 *		Message to log
	 * @return void
	 */
	void trace(string file, int line, string msg) {
		log(LOG4MQL_LEVEL_TRACE, file, line, msg);
	}

	/**
	 * Debug
	 *
	 * Log debug message
	 *
	 * @var string file
	 *		Origin file name which sends the log message (__FILE__)
	 * @var int line
	 *		Line of log method call in origin file (__LINE__)
	 * @var string msg
	 *		Message to log
	 * @return void
	 */
	void debug(string file, int line, string msg) {
		log(LOG4MQL_LEVEL_DEBUG, file, line, msg);
	}

	/**
	 * Info
	 *
	 * Log info message
	 *
	 * @var string file
	 *		Origin file name which sends the log message (__FILE__)
	 * @var int line
	 *		Line of log method call in origin file (__LINE__)
	 * @var string msg
	 *		Message to log
	 * @return void
	 */
	void info(string file, int line, string msg) {
		log(LOG4MQL_LEVEL_INFO, file, line, msg);
	}

	/**
	 * Warn
	 *
	 * Log warn message
	 *
	 * @var string file
	 *		Origin file name which sends the log message (__FILE__)
	 * @var int line
	 *		Line of log method call in origin file (__LINE__)
	 * @var string msg
	 *		Message to log
	 * @return void
	 */
	void warn(string file, int line, string msg) {
		log(LOG4MQL_LEVEL_WARN, file, line, msg);
	}

	/**
	 * Error
	 *
	 * Log error message
	 *
	 * @var string file
	 *		Origin file name which sends the log message (__FILE__)
	 * @var int line
	 *		Line of log method call in origin file (__LINE__)
	 * @var string msg
	 *		Message to log
	 * @return void
	 */
	void error(string file, int line, string msg) {
		log(LOG4MQL_LEVEL_ERROR, file, line, msg);
	}

	/**
	 * Crit
	 *
	 * Log critical message
	 *
	 * @var string file
	 *		Origin file name which sends the log message (__FILE__)
	 * @var int line
	 *		Line of log method call in origin file (__LINE__)
	 * @var string msg
	 *		Message to log
	 * @return void
	 */
	void crit(string file, int line, string msg) {
		log(LOG4MQL_LEVEL_CRIT, file, line, msg);
	}

private:
	/**
	 * Log
	 *
	 * Create a log message (console / log file)
	 * Called by trace, debug, info, warn, error and crit methods
	 *
	 * Different targets per run mode
	 *
	 *                File   Console
	 *	Normal			x		x
	 *	Testing			x		-
	 * 	Optimization	-		-
	 *
	 * @var int level
	 *		Level of log message
	 * @var string file
	 *		Origin file name which sends the log message (__FILE__)
	 * @var int line
	 *		Line of log method call in origin file (__LINE__)
	 * @var string msg
	 *		Message to log
	 * @return void
	 */
	void log(int level, string file, int line, string msg) {
		if(IsOptimization()) {
			return;
		}
		if(!IsTesting()) {
			logToConsole(level, file, line, msg);
		}
		logToFile(level, file, line, msg);
	}

	/**
	 * LogToConsole
	 *
	 * Log a message to MetaTrader console
	 *
	 * @var int level
	 *		Level of log message
	 * @var string file
	 *		Origin file name which sends the log message (__FILE__)
	 * @var int line
	 *		Line of log method call in origin file (__LINE__)
	 * @var string msg
	 *		Message to log
	 * @return void
	 */
	void logToConsole(int level, string file, int line, string msg) {
		if(level <= getFileLevel(file)) {
			PrintFormat("%-8s [%-20s:%-3d] %s", levelToString(level), file, line, msg);
		}
	}

	/**
	 * LogToFile
	 *
	 * Log a message to log file
	 *
	 * @var int level
	 *		Level of log message
	 * @var string file
	 *		Origin file name which sends the log message (__FILE__)
	 * @var int line
	 *		Line of log method call in origin file (__LINE__)
	 * @var string msg
	 *		Message to log
	 * @return void
	 */
	void logToFile(int level, string file, int line, string msg) {
		if(confLogFile == "off") {
			return;
		}
		openLogFile();
		if(logFileHandle == INVALID_HANDLE) {
			return;
		}
		if(level <= getFileLevel(file)) {
			int bytes = (int) FileWriteString(logFileHandle, StringFormat("%s %-8s [%-20s:%-3d] %s\n", getDate(),
					levelToString(level), file, line, msg));
			if(bytes <= 0) {
				Print("LOG4MQL ERROR: Failed to write to logfile " + confLogFile);
				closeLogFile();
			}
			FileFlush(logFileHandle);
			actionsLastRotate++;	
			if(confRotateEnabled && actionsLastRotate >= confRotateCheckPeriod) {
				actionsLastRotate = 0;
				if(FileSize(logFileHandle) >= confRotateSize) {
					rotate();
				}
			}
		}
	}

	/**
	 * GetDate
	 *
	 * Generate date string for log file message
	 *
	 * @return string
	 *		Date in format YYYY-MM-DD hh:mm:ss
	 */
	string getDate() {
		datetime t = TimeLocal();
		return StringFormat("%04d-%02d-%02d %02d:%02d:%02d", TimeYear(t), TimeMonth(t), TimeDay(t), TimeHour(t),
				TimeMinute(t), TimeSeconds(t));
	}

	/**
	 * OpenLogFile
	 *
	 * @return void
	 */
	void openLogFile() {
		if(logFileHandle != INVALID_HANDLE) {
			return;
		}
		logFileHandle = FileOpen(confLogFile, FILE_WRITE|FILE_SHARE_WRITE|FILE_READ|FILE_SHARE_READ|FILE_TXT);
		if(logFileHandle == INVALID_HANDLE) {
			Print("LOG4MQL ERROR: Failed to open logfile " + confLogFile);
			return;
		}
		FileSeek(logFileHandle, 0, SEEK_END);
	}

	/**
	 * CloseLogFile
	 *
	 * @return void
	 */
	void closeLogFile() {
		if(logFileHandle != INVALID_HANDLE) {
			FileClose(logFileHandle);
			logFileHandle = INVALID_HANDLE;
		}
	}

	/**
	 * Rotate
	 *
	 * Rotate logfiles / delete old rotated log files
	 * 
	 * Example for 4 Generations:
	 *	log4mql.log		-> log4mql.log.1
	 *	log4mql.log.1	-> log4mql.log.2
	 *	log4mql.log.2	-> log4mql.log.3
	 *	log4mql.log.3	-> log4mql.log.4
	 *	log4mql.log.4	-> delete
	 *
	 * @return void
	 */
	void rotate() {
		if(!confRotateEnabled) {
			return;
		}
		if(!FileIsExist(confLogFile)) {
			return;
		}
		info(__FILE__, __LINE__, "Rotate");
		closeLogFile();
		string delFile = confLogFile + "." + IntegerToString(confRotateGenerations);
		if(FileIsExist(delFile)) {
			info(__FILE__, __LINE__, "  delete %s" + delFile);
			FileDelete(delFile);
		}
		for(int i = confRotateGenerations - 1; i >= 0; i--) {
			string fileFrom;
			if(i > 0) {
				fileFrom = confLogFile + "." + IntegerToString(i);
			} else {
				fileFrom = confLogFile;
			}
			if(!FileIsExist(fileFrom)) {
				continue;
			}
			string fileTo = confLogFile + "." + IntegerToString(i + 1);
			info(__FILE__, __LINE__, StringFormat("  %-20s =>   %s", fileFrom, fileTo));
			FileMove(fileFrom, 0, fileTo, 0);
		}
		FileDelete(confLogFile);
		openLogFile();
	}

	/**
	 * LoadConfig
	 *
	 * Read log4mql configuration from 
	 *	Normal mode:	<MetaTrader DataDir>/Files/log4mql.conf
	 *	Test mode:		<MetaTrader DataDir>/tester/files/log4mql.conf
	 *
	 * @return void
	 */
	void loadConfig() {
		if(!FileIsExist(LOG4MQL_CONFFILE)) {
			warn(__FILE__, __LINE__, "No configuration file " + LOG4MQL_CONFFILE + " found");
			return;
		}
		int confFileHandle = FileOpen(LOG4MQL_CONFFILE, FILE_READ);
		if(confFileHandle == INVALID_HANDLE) {
			warn(__FILE__, __LINE__, "Failed to read configuration file " + LOG4MQL_CONFFILE);
			return;
		}
		while(!FileIsEnding(confFileHandle)) {
			string line = FileReadString(confFileHandle);
			StringReplace(line, " ", "");
			StringReplace(line, "\t", "");
			string key = getConfigEntry(line, 0);
			string value = getConfigEntry(line, 1);
			if(key == "" || value == "") {
				continue;
			}
			if(key == "defaultLevel") {
				confDefaultLevel = stringToLevel(value);
			} else if(key == "logfile") {
				confLogFile = value;
				debug(__FILE__, __LINE__, StringFormat("Config %-20s = %s", key, value));
			} else if(key == "rotateEnable") {
				if(value == "true") {
					confRotateEnabled = true;
					debug(__FILE__, __LINE__, StringFormat("Config %-20s = %s", key, "ENABLED"));
				} else {
					confRotateEnabled = false;
					debug(__FILE__, __LINE__, StringFormat("Config %-20s = %s", key, "DISABLED"));
				}
			} else if(key == "rotateCheckPeriod") {
				confRotateCheckPeriod = StrToInteger(value);
				debug(__FILE__, __LINE__, StringFormat("Config %-20s = %s", key, value));
			} else if(key == "rotateSizeMb") {
				confRotateSize = (ulong) StrToInteger(value) * 1024 * 1024;
				debug(__FILE__, __LINE__, StringFormat("Config %-20s = %s", key, value));
			} else if(key == "rotateGenerations") {
				confRotateGenerations = StrToInteger(value);
				debug(__FILE__, __LINE__, StringFormat("Config %-20s = %s", key, value));
			} else {
				int level = stringToLevel(value);
				StringToUpper(key);
				StringToUpper(value);
				configFile[configs] = key;
				configLevel[configs] = level;
				configs++;
				debug(__FILE__, __LINE__, StringFormat("Config file %-15s = %s", key, levelToString(level)));
			}
		}
		FileClose(confFileHandle);
	}

	/**
	 * GetConfigEntry
	 *
	 * Parse a config line
	 * Cut comments and whitspaces
	 *
	 * Example 
	 *	Log line: foo   = bar # Comment
	 * 	Key   (col 0) is 'foo'
	 *	Value (col 1) is 'bar'
	 *
	 * @var string line
	 *		Line from configuration file
	 * @var int col
	 *		1 = key
	 *		2 = value
	 * @return string
	 *		Key or value
	 *      Empty string if
	 *			Parse failed
	 *			Line empty
	 *			Comment line
	 */
	string getConfigEntry(string line, int col) {
		if(StringFind(line, "=") == EMPTY) {
			return "";
		}
		int comment = StringFind(line, "#");
		if(comment == 0) {
			return "";
		} else if(comment > 0) {
			line = StringSubstr(line, 0, comment - 1);
		}
		string spl[];
		StringSplit(line, StringGetCharacter("=", 0), spl);
		string s = spl[col];
		StringTrimLeft(s);
		StringTrimRight(s);
		return s;
	}

	/**
	 * GetFileLevel
	 *
	 * Get loglevel for origin file of log message from configuration / default
	 *
	 * @var string file
	 *		Origin file of log message
	 * @return int
	 * 		Log level
	 */
	int getFileLevel(const string file) {
		string f = file;
		StringReplace(f, ".mqh", "");
		StringReplace(f, ".mq4", "");
		StringToUpper(f);
		for(int i = 0; i < configs; i++) {
			if(configFile[i] == f) {
				return configLevel[i];
			}
		}
		return confDefaultLevel;
	}

	/**
	 * LevelToString
	 *
	 * Convert level integer to string
	 *
	 * @var int l
	 *		Level to convert
	 * @return string
	 *		Log level string
	 */
	string levelToString(int l) {
		switch(l) {
			case LOG4MQL_LEVEL_TRACE:
				return "TRACE";
			case LOG4MQL_LEVEL_DEBUG:
				return "DEBUG";
			case LOG4MQL_LEVEL_INFO:
				return "INFO";
			case LOG4MQL_LEVEL_WARN:
				return "WARNING";
			case LOG4MQL_LEVEL_ERROR:
				return "ERROR";
			case LOG4MQL_LEVEL_CRIT:
				return "CRITICAL";
			default:
				return "";
		}
	}

	/**
	 * StringToLevel
	 *
	 * Convert string to level integer
	 *
	 * @var string s
	 *		Level string to convert
	 * @return int
	 *		Log level
	 */
	int stringToLevel(string s) {
		StringToUpper(s);
		if(s == "TRACE") {
			return LOG4MQL_LEVEL_TRACE;
		} else if(s == "DEBUG") {
			return LOG4MQL_LEVEL_DEBUG;
		} else if(s == "WARN" || s == "WARNING") {
			return LOG4MQL_LEVEL_WARN;
		} else if(s == "ERROR") {
			return LOG4MQL_LEVEL_ERROR;
		} else if(s == "CRIT" || s == "CRITICAL") {
			return LOG4MQL_LEVEL_CRIT;
		} else {
			return confDefaultLevel;
		}
	}
};

/**
 * Initialize singleon
 */
CLog4mql * CLog4mql::instance = NULL;

#endif /* __LOG4MQL__ */
