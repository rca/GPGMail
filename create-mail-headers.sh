if [ -z "$1" ]; then
	echo "Output directory has to be specified!"
	exit 1
fi

ROOT="/"
OUTDIR="$1"

if [[ -n "$2" && -d "$2" ]]; then
	ROOT="$2"
fi

class-dump -I -H -o "$OUTDIR/MailUI" "$ROOT/Applications/Mail.app/Contents/MacOS/Mail"
class-dump -I -H -o "$OUTDIR/EmailAddressing" "$ROOT/System/Library/PrivateFrameworks/EmailAddressing.framework/EmailAddressing" 
class-dump -I -H -o "$OUTDIR/MailCore" "$ROOT/System/Library/PrivateFrameworks/MailCore.framework/MailCore"
class-dump -I -H -o "$OUTDIR/MailUIFW" "$ROOT/System/Library/PrivateFrameworks/MailUI.framework"
class-dump -I -H -o "$OUTDIR/MailFW" "$ROOT/System/Library/PrivateFrameworks/Mail.framework"
