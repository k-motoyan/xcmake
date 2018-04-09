require "logger"
require "colorize"

module Xcmake
  module Logger
    def log_info(text)
      stdout_logger.info(text.green)
    end

    def log_error(text)
      stdout_logger.error(text.red)
    end

    def log_error!(text)
      log_error(text)
      exit 1
    end

    private

    def stdout_logger
      create_logger(STDOUT)
    end

    def stderr_logger
      create_logger(STDERR)
    end

    def create_logger(output)
      logger = ::Logger.new(output)
      logger.progname = "Xcmake"
      logger.formatter =  proc { |severity, datetime, progname, message|
        "#{progname} : #{message}\n"
      }
      logger
    end
  end
end
