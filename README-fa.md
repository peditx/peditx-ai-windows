# دستیار هوشمند PeDitX-AI برای Windows

یک دستیار شخصی و لوکال برای ویندوز با دو رابط: CLI در ترمینال و وب‌UI دسکتاپ روی loopback. به هر API سازگار با OpenAI Chat Completions وصل می‌شود؛ کلید و تاریخچه روی همان کامپیوتر شما می‌ماند. هستهٔ Python فقط با کتابخانهٔ استاندارد است؛ بدون وابستگی PyPI.

این نسخه پورت ویندوزی پروژهٔ اصلی [PeDitX-AI برای Linux](https://github.com/peditx/PeDitX-AI) است.

## نصب

### نصب با installer (پیشنهادی)

۱. آخرین نسخه را از [Releases](https://github.com/peditx/peditx-ai-windows/releases) دانلود و `PeDitX-AI-Setup-x64.exe` را اجرا کنید. نصب per-user است و نیازی به Administrator ندارد.
۲. از منوی Start، «PeDitX-AI» را باز کنید؛ مرورگر به‌صورت خودکار روی `http://127.0.0.1:8765` باز می‌شود.
۳. در Settings آدرس مدل (مثلاً `http://127.0.0.1:20128/v1`)، مدل و کلید API را وارد و Save کنید.

### نصب از روی کد

```powershell
git clone https://github.com/peditx/peditx-ai-windows.git
cd peditx-ai-windows
powershell -NoProfile -ExecutionPolicy Bypass -File install\install.ps1
```

یا بدون نصب، مستقیم اجرا کنید (Python 3.10+ لازم است):

```powershell
$env:PYTHONPATH="src"; python -m peditx_ai
```

### ساخت exe و installer از روی کد

کامپایل فقط روی GitHub Actions انجام می‌شود؛ ساخت local نداریم. برای ساخت CI، همان `.github/workflows/build.yml` را دنبال می‌کند یا مخزن builder را dispatch کنید.

## Workspace و فایل‌های پیوست

- پیکربندی و حافظه‌ها: `%APPDATA%\peditx-ai`
- تاریخچهٔ گفتگوها و پیوست‌ها: `%LOCALAPPDATA%\peditx-ai`
- پوشهٔ کاری پیش‌فرض: `PeDitX-AI-Workspace` در Home شما؛ از تنظیمات قابل تغییر است. مسیرهای سیستمی (`C:\Windows`، `Program Files`، `AppData` و ریشهٔ درایوها) پذیرفته نمی‌شوند.

فایل‌های PDF، DOCX و ODT هنگام پیوست به‌صورت محلی متن‌شان استخراج می‌شود (PDF به `pdftotext` از Poppler روی PATH نیاز دارد). تصاویر PNG/JPEG/GIF/WebP تا ۸ مگابایت هر کدام؛ سقف کل پیوست‌ها ۵۰ مگابایت است.

## استفاده در موبایل و نصب به‌شکل PWA

وب‌UI فقط روی `127.0.0.1` گوش می‌دهد و به هیچ دستگاه دیگری سرویس نمی‌دهد؛ از بیرون قابل دسترسی نیست. از مرورگر می‌توان آن را به‌شکل PWA نصب کرد.

## هویت، حافظه و Skills

- فایل‌های `user.md`، `memory.md` و `long-term-memory.md` در `%APPDATA%\peditx-ai\instructions` هستند و از همان‌جا در وب‌UI قابل مشاهده و ویرایش‌اند.
- `personality.md` ثابت است و نه کاربر و نه دستیار قابل تغییرش نیست.
- Skills در `~\.claude\skills` (یا `%USERPROFILE%\.claude\skills`) نصب می‌شوند؛ هر پوشه باید `SKILL.md` با frontmatter داشته باشد.

## اتصال SSH و SMB

- SSH: از کلاینت OpenSSH خود ویندوز استفاده می‌کند؛ باید قبلاً نصب شده باشد (Settings → Optional features → OpenSSH Client). میزبان باید در `known_hosts` تأیید شده باشد و PeDitX-AI هرگز کلید خصوصی یا رمز SSH را نمی‌خواند و نگه نمی‌دارد. در حالت Limited فقط عملیات خواندنی ساخت‌یافته مجاز است.
- SMB: از اتصال شبکهٔ ویندوز (`net use`) استفاده می‌کند؛ اگر share در File Explorer با credential ذخیره‌شده وصل شده باشد، همان درایو به‌عنوان Workspace تنظیم می‌شود. رمز SMB هرگز در پرامپت، فرمان یا تنظیمات برنامه قرار نمی‌گیرد.

## سطح دسترسی

| حالت | رفتار |
| --- | --- |
| Limited · read only | فقط خواندن فایل‌های Home و Workspace و اطلاعات سیستم؛ بدون تغییر |
| Plan · inspect and propose | بازبینی و پیشنهاد، بدون اجرا |
| Ask every time | هر فرمان و تغییر فایل با تأیید شما |
| Full access | اکثر اقدامات بدون سؤال (با تأیید اولیهٔ صریح) |

در حالت Ask، فقط فهرست کوتاهی از فرمان‌های بی‌خطر (`git`, `ipconfig`, `ping`, `systeminfo`, `dir`, `powershell` و…) اجرا می‌شوند و فرمان‌های مرکب (`&`, `|`, `;`) مسدودند.

## استفاده از CLI

```powershell
peditx-ai --models
peditx-ai --configure
peditx-ai --mode ask --cli
peditx-ai --cli "این فولدر را خلاصه کن"
```

## توقف و حذف

- وب‌UI: دکمهٔ Stop در چت، یا بستن پنجرهٔ کنسول.
- حذف: Settings → Apps → PeDitX-AI، یا `powershell -NoProfile -ExecutionPolicy Bypass -File "$env:LOCALAPPDATA\peditx-ai\uninstall.ps1"`.

## محدودیت نسخهٔ اول

- سرویس لوکال است و پنجرهٔ کنسولِ سرور عمداً باقی می‌ماند؛ بستن پنجره = توقف سرور. آیکن tray هنوز نیست.
- اتصال SMB به shareهایی که credential ذخیره‌شده ندارند خودکار نیست؛ اول در File Explorer وصل کنید.
- auto-updater هنوز پیاده نشده؛ نسخه را از Releases بگیرید.
- PDF reading به نصب جداگانهٔ Poppler روی PATH نیاز دارد.

## معماری و مشارکت

[CONTRIBUTING.md](CONTRIBUTING.md) را ببینید. هسته فقط stdlib است؛ کد سیستم‌محور در همان `src/peditx_ai.py` و با شاخه‌های `os.name == "nt"` می‌ماند. انتشار از مخزن builder روی GitHub Actions انجام می‌شود؛ هرگز locally کامپایل نکنید.
