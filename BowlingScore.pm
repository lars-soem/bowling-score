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

package BowlingScore;

use Mojo::Base -base;
use Mojo::JSON qw(encode_json);
use Mojo::UserAgent;
use FindBin;
use lib "$FindBin::Bin";
use ScoreList;

has 'msg';
has 'url';
has 'ua'  => sub {Mojo::UserAgent->new};

sub running {
   my ($self, $running) = @_;
   if (defined($running)) {
      my $old_running = $self->{running};
      $self->{running} = $running;
      $self->loop if $running && !$old_running;
   }
   return $self->{running};
}

sub text {
   my ($label, $data) = @_;
   return sprintf('%s: %s (length %i)', $label, encode_json($data), scalar(@$data)) if ref($data) eq 'ARRAY';
   return sprintf('%s: %s', $label, $data);
}

sub loop {
   my ($self) = @_;
   return unless $self->running;
   $self->msg->('group');
   $self->ua->get($self->url, sub {
      my ($ua, $tx) = @_;
      eval {
         die(sprintf("Woops, get failed with %i\n", $tx->res->code)) unless $tx->res->code == 200;
         my $input = $tx->res->json;
         $self->msg->('info', text('Token', $input->{token}), text('Input', $input->{points}));
         my $sl = ScoreList->new(frames => $input->{points});
         $self->msg->('info', text('Scores', $sl->scores));
         my $msg = $sl->check;
         $self->msg->('warn', $msg, text('Input', $input->{points})) if $msg;
         $ua->post($self->url, form => {token  => $input->{token}, points => encode_json($sl->scores)}, sub {
            my ($ua, $tx) = @_;
            eval {
               die(sprintf("Woops, post failed with %i\n", $tx->res->code)) unless $tx->res->code == 200;
               if ($tx->res->json->{success}) {
                  $self->msg->('accept', 'Posted data was accepted');
               } elsif ($msg) {
                  $self->msg->('info', 'Posted data was not accepted');
               } else {
                  $self->msg->('error',
                     'Posted data was not accepted',
                     text('Token', $input->{token}),
                     text('Input', $input->{points}),
                     text('Frames', $sl->frames),
                     text('Frame scores', $sl->frame_scores),
                     text('Scores', $sl->scores)
                  );
               }
               $self->loop;
            };
            if ($@) {
               $self->msg->('fatal', $@);
               $self->running(0);
            }
         });
      };
      if ($@) {
         $self->msg->('fatal', $@);
         $self->running(0);
      }
   });
}

return 1;
