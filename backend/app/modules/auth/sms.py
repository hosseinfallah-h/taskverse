"""SMS sender — DISABLED until we own a provider.

Current behavior:
- If SMS_PROVIDER is empty or "disabled": no external calls. OTP is logged
  (dev only) and returned in the API response when DEBUG=true.
- If SMS_PROVIDER is configured (later): will send via configured provider.

Rule: never call a third-party SMS API we don't own.
"""

import logging
from dataclasses import dataclass

from app.core.config import settings

logger = logging.getLogger("taskverse.sms")


@dataclass
class SmsResult:
    """Result of an SMS send attempt."""

    sent: bool
    dev_code: str | None = None  # populated when DEBUG=true and provider disabled


async def send_otp(phone: str, code: str) -> SmsResult:
    """Attempt to send an OTP.

    Until a provider is configured, this is a no-op that surfaces the code in
    dev mode. In production with no provider, it fails loudly.
    """
    provider = (settings.sms_provider or "").strip().lower()

    if provider in ("", "disabled", "none"):
        if settings.debug:
            logger.warning("DEV OTP for %s: %s", phone, code)
            return SmsResult(sent=False, dev_code=code)
        logger.error(
            "SMS provider not configured in production",
            extra={"context": {"phone": phone}},
        )
        return SmsResult(sent=False)

    # Future: real provider dispatch goes here.
    # Intentionally NOT implemented until we own a provider.
    logger.error(
        "SMS provider '%s' is not implemented yet",
        provider,
        extra={"context": {"phone": phone, "provider": provider}},
    )
    return SmsResult(sent=False, dev_code=code if settings.debug else None)
