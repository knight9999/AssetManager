package AssetManager::Plugin;

use strict;

use MT;
use MT::Asset;
use MT::FileMgr;

use AssetManager::Logic;

my $max_converts = 50;


sub file_path_bulk_html {
  my ( $prop, $assets, $app, $opts ) = @_;
  # load objectassets
  my @asset_ids = map { $_->id } @$assets;
  my @obj_assets = $app->model('objectasset')->load( { asset_id => \@asset_ids, } );

  my @rows;
  for my $asset (@$assets) {
  my $path = $asset->MT::Asset::SUPER::file_path();
    push @rows, $path;
  }
  return @rows;
}

sub hndl_method {
  my $app = shift;
  my $plugin = MT->component('AssetManager');
  my $blog_id = $app->param('blog_id');
  my $blog = MT::Blog->load($blog_id);
  my $method = $app->param->request_method();

  if (! $blog) {
    return $app->redirect( $app->uri . "?blog_id=0&__mode=dashboard");
  }   

  if ($app->param('commit') ) {
    return action_finish($app);
  }
  
  my $common_path = "";
  
  my @ids = $app->param('id');
  
  
  my $my_max = MT->config->AssetManagerMaxSize || $max_converts;
  
  
  if (scalar( @ids ) > $my_max) {
    my %param;
    $param{message} = "Too much items are selected. Please smaller than " . $my_max . ". You can set this value by AssetManagerMaxSize parameter in mt-config.";
#    $param{max_converts} = $my_max;
    return $app->load_tmpl('error.tmpl',\%param);
  } 
  
  for my $asset_id (@ids) {
    my $asset = MT::Asset->load( $asset_id );
    if ($asset->blog_id != $blog_id) {
      my %param;
      $param{message} = "All assets must blongs_to blog " . $blog->name . "(" . $blog->id . ")";;
      return $app->load_tmpl('error.tmpl',\%param);
    }
    if ($asset->parent) {
      my %param;
      $param{message} = "Assets with parent can not moved ( for asset id = " . $asset_id . ")";
      return $app->load_tmpl('error.tmpl',\%param);
      
    }
  }      
  
  
  for my $id (@ids) {
    my $asset = MT::Asset->load( $id );
    my $path = $asset->MT::Asset::SUPER::file_path();

    if ($common_path) {
        $common_path = common_path_of( $common_path , $path );
    } else {
        $common_path = $path;
    }
  }
  
  $common_path =~ s!\/[^\/]+$!\/!;
  
  my %param;
  $param{max_converts} = $my_max;
  $param{old_path} = $common_path;
  $param{new_path} = $common_path;
  $param{asset_ids} = join(',',@ids);
  $param{assets_count} = scalar( @ids );
  $param{flag_change_entries} = 1;
  $param{flag_change_assets} = 1;
  $param{flag_test} = 1;
  $app->load_tmpl('input.tmpl',\%param);
}

sub action_condition {
  my $prop = shift;
  my $app = MT->app or return;
  return $app->blog;
}

sub common_path_of { # assume $a is shorter than $b;
    my ($a,$b) = @_;  
    my @achars = split //, $a;
    my @bchars = split //, $b;
    
    my $size = scalar(@achars) < scalar(@bchars) ? scalar(@achars) : scalar(@bchars);
    my $str = "";
    for (my $i=0;$i<$size;$i++) {
      if ($achars[$i] eq $bchars[$i]) {
        $str .= $achars[$i];
      } else {
        last;
      }
    }
    if ($str =~ /^(.+\/)[^\/]+$/) {
        $str = $1;
    }
    return $str;
}


sub action_finish {
    my $app = shift;
    my $plugin = MT->component('AssetManager');
    my $blog_id = $app->param('blog_id');
    my $blog = MT::Blog->load($blog_id);
    my $method = $app->param->request_method();
    my $asset_ids_str = $app->param('asset_ids');
    my @asset_ids = split(/,/,$app->param('asset_ids') );
   
    my $flag_change_entries = $app->param('flag_change_entries');
    my $flag_change_assets = $app->param('flag_change_assets');
    my $my_max = MT->config->AssetManagerMaxSize || $max_converts;

    my $flag_test = $app->param('flag_test');
    if (! $blog) {
      return $app->redirect( $app->uri . "?blog_id=0&__mode=dashboard");
    }   
    
    my $old_path = $app->param('old_path');
    my $new_path = $app->param('new_path');

    my $result = AssetManager::Logic::convert( $app , {
      blog_id => $blog_id, 
      asset_ids_str => $asset_ids_str, 
      flag_change_entries => $flag_change_entries,
      flag_change_assets => $flag_change_assets, 
      old_path => $old_path, 
      new_path => $new_path ,
      flag_test => $flag_test
    } );

    if ($flag_test || ! $result->{success}) {
      my %param;
      $param{max_converts} = $my_max;
      $param{validate_message} = $result->{message};
      $param{old_path} = $old_path;
      $param{new_path} = $new_path;
      $param{asset_ids} = $asset_ids_str;
      $param{assets_count} = scalar( @asset_ids ); 
      $param{flag_change_entries} = $flag_change_entries;
      $param{flag_change_assets} = $flag_change_assets;
      $param{flag_test} = $flag_test;
      $param{test_result} = $result->{success} if $flag_test;
      return $app->load_tmpl('input.tmpl',\%param);
    }

    my %param;
    $app->load_tmpl('finish.tmpl',\%param);
}

sub h {
  my ($str) = @_;
  return Encode::encode( MT->config->PublishCharset || 'UTF-8', $str );
}




1;
