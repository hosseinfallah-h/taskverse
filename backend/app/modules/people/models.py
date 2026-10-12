"""SQLAlchemy model for people."""

from datetime import date, datetime

from sqlalchemy import BigInteger, Column, Date, ForeignKey, Integer, String, Table, Text
from sqlalchemy.orm import Mapped, mapped_column

from app.core.database import Base

person_tags = Table(
    "person_tags",
    Base.metadata,
    Column(
        "person_id",
        BigInteger,
        ForeignKey("people.id", ondelete="CASCADE"),
        primary_key=True,
    ),
    Column(
        "tag_id",
        BigInteger,
        ForeignKey("tags.id", ondelete="CASCADE"),
        primary_key=True,
    ),
)


class Person(Base):
    __tablename__ = "people"

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True)
    user_id: Mapped[int] = mapped_column(BigInteger, nullable=False)
    name: Mapped[str] = mapped_column(String(100), nullable=False)
    nickname: Mapped[str | None] = mapped_column(String(100))
    phone: Mapped[str | None] = mapped_column(String(20))
    email: Mapped[str | None] = mapped_column(String(255))
    birthday: Mapped[date | None] = mapped_column(Date)
    avatar_path: Mapped[str | None] = mapped_column(Text)
    notes: Mapped[str | None] = mapped_column(Text)
    relationship: Mapped[str] = mapped_column(String(30), default="friend")
    sort_order: Mapped[int] = mapped_column(Integer, default=0)
    created_at: Mapped[datetime] = mapped_column(default=datetime.utcnow)
    updated_at: Mapped[datetime] = mapped_column(default=datetime.utcnow)
    deleted_at: Mapped[datetime | None] = mapped_column()
