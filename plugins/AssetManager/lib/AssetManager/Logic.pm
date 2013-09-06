package AssetManager::Logic;

use strict;
use POSIX;

use File::Basename;
use MT;
use MT::Entry;
use MT::Asset;
use MT::FileMgr;


sub convert {
  my $app = shift;
  my $args = shift;
  my ($blog_id , $asset_ids, $flag_change_entries, $flag_change_assets, $old_path, $new_path, $flag_test)
   = map { $args->{$_} } ( 'blog_id' , 'asset_ids_str', 'flag_change_entries', 'flag_change_assets', 'old_path', 'new_path' , 'flag_test' );

  my $blog = MT::Blog->load($blog_id);
  my @asset_ids = split(/,/,$asset_ids );

  my $test_string = $flag_test ? "(test mode)":"";
  my $plugin = MT->component('AssetManager');
    
  my $log_messages = [];
  local_log( "Convert starts $test_string" . POSIX::strftime("%Y/%m/%d %H:%M:%S",localtime) );

  my $validate_message = 0;

  # Assets must belong to this blog.
  # Assets with parent can not converted.
  for my $asset_id (@asset_ids) {
    my $asset = MT::Asset->load( $asset_id );
    if ($asset->blog_id != $blog_id) {
      $validate_message = $plugin->translate( 'validation.all assets must blongs_to blog [_1] ( [_2] ).' , $blog->name , $blog->id );
      last;
    } 
    if ($asset->parent) {
      $validate_message = $plugin->translate( 'validation.asset [_1] can not moved because of parent.' , $asset_id );
      last;
    }
  }
  
  my $fmgr = MT::FileMgr->new('Local');
  my $root = $blog->site_path;
  $root =~ s!(/|\\)$!!;
  my $root_url = $blog->site_url;
  $root_url =~ s!(/|\\)$!!;

  my @new_path_splits = split('/',$new_path);

  if (! $validate_message) {	   
    if ($new_path !~ /^%r/) {
      $validate_message = $plugin->translate( 'validation.new path must be start with %r.' );
    } elsif ($new_path !~ /\/$/) {
      $validate_message = $plugin->translate( 'validation.new path must be end with /.' );
    } elsif ($new_path eq $old_path) {
      $validate_message = $plugin->translate( 'validation.new path must be different from old path.' );
    } elsif (! $fmgr->exists( $root )) {
      $validate_message = $plugin->translate( 'validation.no root directory [_1].' ,  $root ) ;
    }
  }
  
  if (! $validate_message) {
    foreach my $chunk (@new_path_splits) {
      if ($chunk =~ /^\.{1,2}$/) {
        $validate_message = $plugin->translate(  'validation.invalid path.' );
      }
    }
  }
  
  if ($validate_message) {
  	return { success => 0 , message => $validate_message } ;
  }

  my $dircache = {};
  if (! can_write_dir($root,$fmgr,$dircache)) {
    $validate_message = $plugin->translate( 'validation.directory [_1] can not be written.' ,  $root );
  } 
  
  if ($validate_message) { # second type of validation
  	return { success => 0 , message => $validate_message } ;
  }
  
  
  
  my $old_url = $old_path;
  my $new_url = $new_path;
    
  for my $asset_id (@asset_ids) {

    local_log( "> asset: " . $asset_id   );	

    my $asset = MT::Asset->load( $asset_id );

    my $old_abs_file_url = $asset->url;
    my $old_abs_file_path = $asset->file_path;
        
    my $old_file_path = $asset->MT::Asset::SUPER::file_path();
    my $new_file_path = $old_file_path;
    my $quote_old_path = quotemeta $old_path;
    $new_file_path =~ s!^$quote_old_path!$new_path!;

    my $old_file_url = $asset->MT::Asset::SUPER::url();
    my $new_file_url = $old_file_url;
    my $quote_old_url = quotemeta $old_url;
    $new_file_url =~ s!^$quote_old_url!$new_url!;

    if (! $flag_test) {
      $asset->file_path($new_file_path);
      $asset->url($new_file_url);

      $asset->save;
    }
#    $asset->clear_cache;
#    my $new_abs_file_path = $asset->file_path;		
#    my $new_abs_file_url = $asset->url;

    my $new_abs_file_path = $new_file_path;
    my $new_abs_file_url  = $new_file_url;
    
    $new_abs_file_path =~ s!^%r!$root!;
    $new_abs_file_url =~ s!^%r!$root_url!;  
    		
    # make dir & save file
    my ($basename, $dir, $ext) = fileparse($new_abs_file_path, qr/\.[^.]*/);
    unless($fmgr->exists($dir)) {
      if ( can_write_dir($dir,$fmgr,$dircache) ) {
        if (! $flag_test) {
          $fmgr->mkpath($dir);
        } 
      } else {
        if (! $flag_test) {
          die( $fmgr->errstr );
        } else {
          return { success => 0  , message => $plugin->translate( 'validation.directory [_1] can not be written.' ,  $dir ) };
        }
      }
    }
    if (! $flag_test) {   
      if ($fmgr->exists( $old_abs_file_path) ) {
        $fmgr->rename( $old_abs_file_path , $new_abs_file_path ) || die( $fmgr->errstr );
      }
    } else {
      if ( ! can_write_file( $new_abs_file_path , $fmgr,$dircache ) ) {
         return { success => 0  , message => $plugin->translate( 'validation.file [_1] can not be written.' , $new_abs_file_path ) };
      } 
    }

    if ($flag_change_entries) {
      replace_entries( $app , $asset->blog_id, $old_abs_file_url , $new_abs_file_url , $log_messages,$flag_test,$dircache);
    }
    if ($flag_change_assets) {
      replace_assets( $app , $asset->blog_id, $old_abs_file_url , $new_abs_file_url , $log_messages,$flag_test,$dircache);
    }
    if (! $flag_test) {
      local_log( "file move: '" . $old_abs_file_path . "' -> '" . $new_abs_file_path , $log_messages );	
    }
  }
  my $log_message = join( "\n" , @$log_messages );
  $app->log(
    { message => "Change asset file paths",
      metadata => $log_message,
      level => MT::Log::INFO(),
      class => 'asset_manager',
      blog_id => $blog_id,
      category => 'change_path',
    }
  );
  
  return { success => 1 }; 
}



sub replace_entries {
  my ($app,$blog_id,$old_url,$new_url,$log_messages,$flag_test,$dircache) = @_;
  my $iter = MT::Entry->load_iter( { blog_id => $blog_id } );
  my $quoted_old_url = quotemeta $old_url;

  while (my $entry = $iter->()) {
    my $text = $entry->text;
    my $text_more = $entry->text_more;
    my $excerpt = $entry->excerpt;

    my $num1 = ( $text =~ s!$quoted_old_url!$new_url!g );
    my $num2 = ( $text_more =~ s!$quoted_old_url!$new_url!g );
    my $num3 = ( $excerpt =~ s!$quoted_old_url!$new_url!g );

    if ($num1>0 || $num2>0 || $num3>0) {
        local_log( "> Entry: " . $entry->id );
    }
    if (! $flag_test) {
      if ($num1>0) {
          $entry->text( $text );
          local_log( "change text: Entry " . $entry->id . " with  " . $num1 . " times." , $log_messages );
      }
      if ($num2>0) {
          $entry->text_more( $text_more );
          local_log( "change text_more: Entry " . $entry->id . " with  " . $num2 . " times." , $log_messages );
      }
      if ($num3>0) {
          $entry->excerpt( $excerpt );
          local_log( "change excerpt: Entry " . $entry->id . " with " . $num3 . " times." , $log_messages );
      }
      if ($num1>0 || $num2>0 || $num3>0) {
        $entry->save;
      }
    }
  }
  
}

sub replace_assets {
  my ($app,$blog_id,$old_url,$new_url,$log_messages,$flag_test,$dircache) = @_;
  my $iter = MT::Asset->load_iter( { blog_id => $blog_id , class=> 'file' , file_ext => 'html' } );
  my $quoted_old_url = quotemeta $old_url;
  my $fmgr = MT::FileMgr->new('Local');
  my $plugin = MT->component('AssetManager');

  while (my $asset = $iter->()) {
    if (my $data = $fmgr->get_data( $asset->file_path ) ) {
        my $num = ( $data =~ s!$quoted_old_url!$new_url!g );
        if ($num>0) {
          local_log( "> asset html: " . $asset->id );
          if (! $flag_test) {
            $fmgr->put_data($data,$asset->file_path);
            local_log( "change html: " . $asset->file_path , $log_messages );
          } else {
            if ( ! can_write_file( $asset->file_path , $fmgr,$dircache ) ) {
              return { success => 0  , message => $plugin->translate( 'validation.file [_1] can not be written.' ,  $asset->file_path ) };
            }
          }
        }
     }
  }

}

sub can_write_dir {
  my $target_dir = shift;
  my $fmgr = shift;
  my $cache = shift;
 
  if ($cache->{$target_dir}) {
    return 1;
  }

  my @splits = split( "/" , $target_dir );
  
  for (my $i=scalar(@splits)-1;$i>=0;$i--) {
    my @parts = @splits[0..$i];
    my $subdir = join( "/" , @parts );
    local_log( "check dir : " . $subdir );
    if ($cache->{$subdir}) {
      return 1;
    } elsif ($fmgr->exists($subdir)) {
      local_log( "exist dir : " . $subdir );
      if ( $fmgr->can_write( $subdir ) ) {
        local_log( "stock writable_dir : " . $subdir );
        $cache->{$subdir} = 1;
        return 1;
      } else {
        local_log( "can't write dir : " . $subdir );
        return 0;
      }
    }
  }
  
  local_log( "I can't write dir : " . $target_dir );
  return 0;  
  
}

sub can_write_file {
  my $target_file = shift;
  my $fmgr = shift;
  my $cache = shift;

  if ($fmgr->exists( $target_file )) {
    if ($fmgr->can_write( $target_file )) {
      return 1;
    }
    local_log( "I can't write file : " . $target_file );
    return 0;  
  }
  
  my ($basename, $dir, $ext) = fileparse($target_file, qr/\.[^.]*/);
  return can_write_dir( $dir , $fmgr , $cache );
  
}

sub local_log {
  my ($message,$log_messages) = @_;
  
  if (! MT->config->AssetManagerLocalLogOff) { 
    my $dir = MT->config->AssetManagerLocalLogFile || "/tmp";
    $dir =~ s!(/|\\)$!!;
    if (-w $dir) {
      my $file = $dir . "/" . "asset_manager_log_" . POSIX::strftime("%Y%m%d",localtime);
      open OUT , ">>$file";
      print OUT ($message . "\n");
      close OUT;
    }
  }
  if ($log_messages) {
    push @$log_messages , $message;
  }
  
}


1;
