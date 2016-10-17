#!/usr/bin/perl

# Copyright (C) 2016 Lars Hansen <lh@soem.dk>
# 
# Author: Lars Hansen <lh@soem.dk>
# 
# License:
# 
#   This package is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#   
#   This package is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
#   GNU General Public License for more details.
#   
#   The GNU General Public License may be found at <http://www.gnu.org/licenses/>.
# 
# On Debian systems, the complete text of the GNU General
# Public License version 3 can be found in "/usr/share/common-licenses/GPL-3".

package ScoreList;

use strict;
use warnings;
use Mojo::Base -base;

sub is_strike {
   my ($self, $frame_no) = @_;
   return $self->frames->[$frame_no]->[0] == 10;
}
sub is_spare_or_strike {
   my ($self, $frame_no) = @_;
   my $frame = $self->frames->[$frame_no];
   return $frame->[0] + $frame->[1] == 10;
}

has 'frame_scores' => sub {
   my ($self) = @_;
   my @scores;
   for (my $i = 0; $i < @{$self->frames}; $i++) {
      $self->frame_no($i);
      $self->ball_no(0);
      my $score = $self->ball_score;
      $score += $self->ball_score;
      $score += $self->ball_score if $self->is_spare_or_strike($i);
      push(@scores, $score);
   }
   return \@scores;
};

has 'scores' => sub {
   my ($self) = @_;
   my @scores = @{$self->frame_scores};
   my $sum = 0;
   return [map {$sum += $_} splice(@scores, 0, 10)];
};

has 'check' => sub {
   my ($self) = @_;
   return 'Too many frames'
      if 10 < @{$self->frames} && !$self->is_spare_or_strike(9)
      || 11 < @{$self->frames} && !($self->is_strike(9) && $self->is_strike(10))
      || 12 < @{$self->frames};
   return 'Can\'t determin score of 10th frame since only one ball follows'
       if 11 == @{$self->frames} && $self->is_strike(9);
   return 'Can\'t determin score of last frame since it is a ' . ($self->is_strike($#{$self->frames}) ? 'strike' : 'spare')
       if @{$self->frames} && $self->is_spare_or_strike($#{$self->frames});
   return;
};

has 'frame_no'; # Index of current frame
has 'ball_no';  # Index of current ball in current frame

# Return score of current ball and advance to next ball
sub ball_score {
   my ($self) = @_;
   return 0 if $self->frame_no >= @{$self->frames}; # beyond end of frame list
   my $score = $self->frames->[$self->frame_no]->[$self->ball_no];
   if ($self->ball_no || $self->frames->[$self->frame_no]->[0] == 10) {
      $self->frame_no($self->frame_no + 1); # next frame
      $self->ball_no(0);                    # first ball
   } else {
      $self->ball_no(1); # second ball in current frame
   }
   return $score;
}

sub frames {
   my ($self, $frames) = @_;
   if (defined($frames)) {
      die('frames is not an arrat ref') unless ref($frames) eq 'ARRAY';
      my $i = 0;
      for my $frame (@$frames) {
         die(sprintf(q{Bad frame at position %i}, $i)) unless ref($frame) eq 'ARRAY' && is_frame(@$frame);
         $i++;
      }
      $self->{frames} = $frames;
      undef($self->{check});
      undef($self->{frame_scores});
      undef($self->{scores});
   }
   die('No frames') unless $self->{frames};
   return $self->{frames};
}

sub is_frame {
   return @_ == 2 && is_int($_[0]) && is_int($_[1]) && $_[0] + $_[1] <= 10;
}

sub is_int {
   my ($p) = @_;
   return $p =~ /^\d+$/;
}

return 1;
