#!/usr/bin/env perl6

#Download publications from the "jw.org" site.

use WWW;

#Today's year and month.
my $ym = sprintf "%04d%02d", .year, .month given Date.today;
#Hash to link full names to their short names.
my %publication = (
	awake	=> 'g',
	watchtower	=> 'w',
	workbook	=> 'mwb',
	bible	=> 'nwt'
);

#Make a function to define the usage of this script.
sub USAGE() {
	print Q:c:to/EOF/;
	USAGE: {$*PROGRAM-NAME} [--option=value]

	OPTIONS:
		--pub		Publication name or code to download.
					Defaults to the workbook.

		--date		The issue date for the publication. This must be empty to
					download books.
					Defaults to the current year and month.

		--format	The file format to download the publication into.
					Defaults to EPUB.
	EOF
}

#The main sub to download stuff.
sub MAIN(
	:$pub    = %publication<workbook>,
	:$date   = $ym,
	:$format = 'EPUB',
	:$lang   = 'E'
) {
	#make the URL to request the download link.
	my $jurl =
		'https://apps.jw.org/GETPUBMEDIALINKS?output=json&alllangs=0'
		~ '&issue=' ~ $date
		~ '&pub=' ~ (%publication{$pub} || $pub)
		~ '&fileformat=' ~ $format
		~ '&langwritten=' ~ $lang
		~ '&txtCMSLang=' ~ $lang
	;

	#Get some JSON info about the requested item.
	my $json = jget $jurl;
	#Sort through the JSON and get the URL of the file to download.
	my $url = $json<files>{$lang.uc}{$format.uc}[0]<file><url>;

	#Name the output file.
	my $file = $pub
		~ ($date ?? "-$date" !! "")
		~ ($lang ?? "-$lang" !! "")
		~ "\.{$format.lc}";

	#Download the file's contents and save it.
	say "Getting: $url";
	say "Into file: $file";

	my $fh = $file.IO.open: :w;
	my $curl = Proc::Async.new: «curl $url»;
	$curl.stdout(:bin).tap: -> $chunk { $fh.write: $chunk }
	await $curl.start;
	$fh.close;
}
