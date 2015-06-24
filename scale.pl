#!/usr/bin/perl
use strict; use warnings;

my @chromatic_scale = ( qw/ A Bb B C /, 'C#', qw/ D Eb E F /, 'F#', 'G', 'G#' );
my @sequence = qw/ 2 2 1 2 2 2 1 /;
my @note_types = qw/ Maj m m Maj Maj m dim /;
my @modes = qw/Ionian Dorian Phrygian Lydian Mixolydian Aeolian Locrian/;

unless ( $ARGV[0] && $ARGV[1] ){
    help("Arguments Required");
}

my ( $note, $tone ) = $ARGV[0] =~ m/\A([a-g]{1})(b|\#)?\z/i;
help( "Invalid note input") unless $note;

if ( $tone eq '#' ){
    $note = _normalise_sharp_note( $note, @chromatic_scale );
}
elsif ( $tone eq 'b' ){
    $note = _normalise_flat_note( $note, @chromatic_scale );
}

my $mode;
foreach my $m ( @modes ){
    if ( lc($m) eq lc($ARGV[1]) ){
        $mode = $m; last;
    }
}
help( "Mode not recognised" ) if !$mode;

# Mixolydian is the 5th scale, according to note_types it is a Major scale
my $mode_index = mode_index( $mode ); # 4 ( as an array index )
my $note_index = note_index( $note ); # 0
my $note_type = $note_types[$mode_index]; # Maj

# So, the scale where A is the 5th note

# We are 5th <$mode_index> positions into the major scale interval sequence ( @sequence )
# Move backward from our chosen note using the relative interval
my $sequence_index = $mode_index - 1;
my $chromatic_index = $note_index;
while ( $sequence_index > -1 ) {

    #     <-   <-    <-    *
    #   W    W     h    W
    # D .. E .. F# .. G .. A

    $chromatic_index = minus_index ( $chromatic_index, $sequence[$sequence_index], scalar(@chromatic_scale) );
    $sequence_index--;
}

# Using the major scale interval sequence, print the notes for the relative major scale
my $major_scale = $chromatic_scale[$chromatic_index];

# Our scale is A Mixolydian, the relative Major scale is D Major
my @major_scale_notes = major_notes( $chromatic_index );

my @model_types = rewind_array( $mode_index, @note_types );
my @modal_notes = rewind_array( $mode_index, @major_scale_notes );

my $note_type_index = 0;
my @chords = map { $_.$model_types[$note_type_index++]; } @modal_notes;

print "\n";
print "$note $mode Scale\n\n";
print "Notes: " . join( ", ", @modal_notes ) . "\n";
print "Chords: " . join( ", ", @chords );
print "\n\n";

sub rewind_array {
    my $steps = shift;
    my @array = @_;

    for ( my $i = 0; $i < $steps; $i++ ){
        push @array, shift @array;
    }

    return @array;
}

sub major_notes {
    my $note_index = shift;
    my @notes = ( $chromatic_scale[$note_index] );

    foreach my $seq ( @sequence ) {
        $note_index = add_index( $note_index, $seq, scalar( @chromatic_scale ) );
        push @notes, $chromatic_scale[$note_index]
    }

    pop( @notes );
    return @notes;
}
sub minus_index { 
    my ( $ind, $step, $max ) = @_;
    
    $ind = $ind - $step;

    if ( $ind < 0 ) {
        $ind = $max + $ind;
    }

    return $ind;
}
sub add_index {
    my ( $ind, $step, $max ) = @_;

    $ind = $ind + $step;

    if ( $ind >= $max ) {
        $ind = 0 + $ind - $max;
    }

    return $ind;
}
sub mode_index { return _item_index( $_[0], @modes ); }
sub note_index { return _item_index( $_[0], @chromatic_scale ); }
sub _item_index {
    my $item = shift;
    my @arr = @_;
    my $ind = 0;

    foreach my $n ( @arr ) {
        return $ind if ( $n eq $item );
        $ind++;
    }
}
sub _normalise_flat_note {
    my $note = shift;

    for ( my $i = 0; $i < scalar( @_ ); $i++ ){
        if ( lc($_[$i]) eq lc($note) ){
            if ( $i == 0 ) {
                return $_[-1];
            }
            return $_[$i-1];
        }
    }
}
sub _normalise_sharp_note {
    my $note = shift;

    for ( my $i = 0; $i < scalar( @_ ); $i++ ){
        if ( lc($_[$i]) eq lc($note) ){
            if ( $i == $#_ ) {
                return $_[0];
            }
            return $_[$i+1];
        }
    }
}

sub help {
    my ( $msg ) = @_;
    print "\n$msg\n\n";
    print "First agument should be the name of a note from the chromatic scale... one of:\n";
    print join( ', ', @chromatic_scale );
    print "\n\nSecond argument should be the name of a scale/mode... one of:\n";
    print join( ', ', @modes );
    print "\n\n";
    exit(1);
}
