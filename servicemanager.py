# Minimal stub of pywin32 servicemanager to avoid hard dependency at runtime
# Provides only the APIs used by our service for logging

EVENTLOG_INFORMATION_TYPE = 0x0004
EVENTLOG_ERROR_TYPE = 0x0001

# Pseudo constants used by pywin32 examples
PYS_SERVICE_STARTED = 0x10
PYS_SERVICE_STOPPED = 0x11


def LogMsg(event_type, event_id, args):
    # args is typically (service_name, message)
    try:
        import os
        from datetime import datetime
        log_dir = os.path.join(os.path.dirname(__file__), 'logs')
        os.makedirs(log_dir, exist_ok=True)
        with open(os.path.join(log_dir, 'service.log'), 'a', encoding='utf-8') as f:
            f.write(f"{datetime.now():%Y-%m-%d %H:%M:%S} - SM({event_type:#x},{event_id:#x}) - {args}\n")
    except Exception:
        # Silently ignore logging failures to never block service start
        pass
