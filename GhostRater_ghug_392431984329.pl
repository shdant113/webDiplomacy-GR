#! perl -w
# Implements ratings system devised by TheGhostmaker
# Implemented by Alderian

use Data::Dumper;

$Games = {};
$Players = {};
$Variants = {};
$Exclude = {};

sub CheckForNoProcess
{
    my ($gameNum) = @_;

    if (CheckForExclude($gameNum))
    {
        return 1;
    }

    if ($Games->{$gameNum}{ GameType } =~ m/Points-per-supply-center/i)
    {
        if ($kPPSC != 1)
        {
            return 2;
        }
    }
    elsif ($Games->{$gameNum}{ GameType } =~ m/Unranked/i)
    {

        return 18;
    }
    else
    {
        if ($kWTA != 1)
        {
            return 3;
        }
    }

    if ($Games->{$gameNum}{TurnLength} < 60)
    {
        if ($kLive != 1)
        {
            return 16;
        }
    }
    elsif ($kNonLive != 1)
    {
        return 17;
    }
	
    if ($Games->{$gameNum}{PressType} =~ m/NoPress/i)
    {
        if ($kNoChat != 1)
        {
            return 4;
        }
    }
    elsif ($Games->{$gameNum}{PressType} =~ m/Regular/i)
    {
        if ($kNormalChat != 1)
        {
            return 5;
        }
    }
    elsif ($Games->{$gameNum}{PressType} =~ m/PublicPressOnly/i)
    {
        if ($kPublicPress != 1)
        {
            return 6;
        }
    }


    if (!defined($Variants->{$Games->{$gameNum}{variantID}}))
    {
        return 7;
    }
    if ($Variants->{$Games->{$gameNum}{variantID}}{Active} == 0)
    {
        return 8;
    }

    if ($gameNum < $startID)
    {
        return 9;
    }    
    if ($gameNum > $lastID)
    {
        return 10;
    }

    if ($Games->{$gameNum}{ProcessTime} < $fBeginDate)
    {
        return 11;
    }
    if (($fEndDate != 0) && ($Games->{$gameNum}{ProcessTime} > $fEndDate))
    {
        return 12;
    }
    return 0;
}

sub CalculateGameOutcome
{
    my ($gameNum) = @_;
    my $numDraws = 0;
    my @PPSCResult = ();
    my @WTAResult = ();
    my @SoSResult = ();
    my $SoSDenominator = 0;
    my @ActualResult = ();
    my @SecondPlacePoints = ();
    my @PPSCExpRes = ();
    my @WTAExpRes = ();
    my @SoSExpRes = ();
    my $SoSExpDenominator = 0;
    my @ExpRes = ();
    my @GhostRatings = ();
    my $playerNum = 0;
    my @TranslatePlayerNum = ();
    my $GhostSum = 0;
    my $ppsc = 0;
    my $GamesNum=0;

    if ($debug >= 1)
    {
        open(DEBUGFILE, ">>debug.txt") or die("Unable to open debug.txt file");
        print DEBUGFILE "Game: $gameNum\r\n";
        close(DEBUGFILE);
    }

    if ($Games->{$gameNum}{PressType} =~ m/NoPress/i)
    {
        $VMod2 = $Variants->{-3}{VMod};
    }
    elsif ($Games->{$gameNum}{PressType} =~ m/Regular/i)
    {
        $VMod2 = $Variants->{-1}{VMod};
    }
    elsif ($Games->{$gameNum}{PressType} =~ m/PublicPressOnly/i)
    {
        $VMod2 = $Variants->{-2}{VMod};
    }
    elsif ($Games->{$gameNum}{PressType} =~ m/RulebookPress/i)
    {
        $VMod2 = $Variants->{-4}{VMod};
    }

    $VariantNum = $Games->{$gameNum}{variantID};
    if (defined($Variants->{$Games->{$gameNum}{variantID}}))
    {
        $VPlayers = $Variants->{$VariantNum}{PlayerCount};
        $VMod = $Variants->{$VariantNum}{VMod};
        $VSCCount = $Variants->{$VariantNum}{SCCount};
        $VictorySC = $Variants->{$VariantNum}{VictorySCCount};
        $ModValue = $VMod * $VMod2 * 17.5;
    }
    else
    {
        $VPlayers = 0;
        $VMod = 1;
        $VSCCount = 1;
        $VictorySC = 1;
        $ModValue = $VMod * $VMod2 * 17.5;
    }

    if ($debug >= 5)
    {
        open(DEBUGFILE, ">>debug.txt") or die("Unable to open debug.txt file");
        print DEBUGFILE "Variant: $Variants->{$VariantNum}{PlayerCount} $Variants->{$VariantNum}{VMod} $Variants->{$VariantNum}{SCCount} $Variants->{$VariantNum}{VictorySCCount}\r\n";
        close(DEBUGFILE);
    }
    
    if (($Games->{$gameNum}{ Players } == $VPlayers) and ($Games->{$gameNum}{ GameTurns } > 3) and
        ($Games->{$gameNum}{ GameOutcome } =~ m/Won/ or $Games->{$gameNum}{ GameOutcome } =~ m/Drawn/))
    {
        $NoProcessNum = CheckForNoProcess($gameNum);
        if ($NoProcessNum != 0)
        {
            if ($debug >= 1)
            {
                open(DEBUGFILE, ">>debug.txt") or die("Unable to open debug.txt file");
                print DEBUGFILE "Ignore ".$gameNum." - ".$Games->{$gameNum}{ Players }." - ".$NoProcessNum."\r\n";
                close(DEBUGFILE);
            }
            
            open(NOPROCESS, ">>NotProcessed.txt") or die("Unable to open NotProcessed.txt file");
            print NOPROCESS "$gameNum - $NoProcessNum\r\n";
            close(NOPROCESS);
            return;
        }

        $GamesThisMonth++;
        if ($debug >= 1)
        {
            open(DEBUGFILE, ">>debug.txt") or die("Unable to open debug.txt file");
            print DEBUGFILE "Succeed ".$gameNum." - ".$Games->{$gameNum}{ Players }."\r\n";
            close(DEBUGFILE);
        }
        
        for ($i = 0; $i < $VPlayers ; $i++)
        {
            $Players->{ $Games->{$gameNum}{ $i }{ PlayerID } }{ AwayMonths } = 0;
            $Players->{ $Games->{$gameNum}{ $i }{ PlayerID } }{ LastGame } = $Games->{$gameNum}{ ProcessTime };
            $GhostRatings[$i] = $Players->{ $Games->{$gameNum}{ $i }{ PlayerID } }{ GhostRating };
            $GhostSum = $GhostSum + $GhostRatings[$i];
	    $SoSExpDenominator += $GhostRatings[$i]**2;
            $WTAResult[$i] = 0;
            $PPSCResult[$i] = 0;
	    $SoSResult[$i] = 0;

            if ($debug >= 1)
            {
                open(DEBUGFILE, ">>debug.txt") or die("Unable to open debug.txt file");
                print DEBUGFILE "Player: $Games->{$gameNum}{ $i }{ PlayerID } $GhostRatings[$i] Sum: $GhostSum SoS: $SoSExpDenominator\r\n";
                close(DEBUGFILE);
            }
            
            if ($Games->{$gameNum}{ $i }{ Outcome } =~ m/Draw/i)
            {
                $numDraws++;
		$SoSResult[$i] = $Games->{$gameNum}{ $i }{ SCCount };
		$SoSResult[$i] = $SoSResult[$i]**2;
		$SoSDenominator += $SoSResult[$i];
            }
            else
            {
                if ($Games->{$gameNum}{ $i }{ Outcome } =~ m/Won/i)
                {
                    $WTAResult[$i] = 1;
		    $SoSResult[$i] = 1;
		    $SoSDenominator = 1;
                }
                $PPSCResult[$i] = $Games->{$gameNum}{ $i }{ SCCount } / $VSCCount;
            }
        }

        for ($i = 0; $i < $VPlayers ; $i++)
        {
            $WTAExpRes[$i] = $GhostRatings[$i] / $GhostSum;
	    $SoSExpRes[$i] = $GhostRatings[$i]**2 / $SoSExpDenominator;
            if ($Games->{$gameNum}{ $i }{ Outcome } =~ m/Draw/i)
            {
                $WTAResult[$i] = 1/$numDraws;
                $PPSCResult[$i] = 1/$numDraws;
            }
			elsif ($numDraws > 1)
			{
			    $PPSCResult[$i] = 0;
			}

            if ($Games->{$gameNum}{ GameType } =~ m/Points-per-supply-center/i)
            {
                $ppsc = 1;
                $ActualResult[$i] = $PPSCResult[$i];
            }
            elsif ($Games->{$gameNum}{ GameType } =~ m/Winner-takes-all/i)
            {
                $ppsc = 0;
                $ActualResult[$i] = $WTAResult[$i];
		$ExpRes[$i] = $WTAExpRes[$i];
            }
	    elsif ($Games->{$gameNum}{ GameType } =~ m/Sum-of-squares/i)
            {
                $ppsc = 0;
		$ActualResult[$i] = $SoSResult[$i] / $SoSDenominator;
		$ExpRes[$i] = $SoSExpRes[$i];
            }

            if ($debug >= 1)
            {
                open(DEBUGFILE, ">>debug.txt") or die("Unable to open debug.txt file");
                print DEBUGFILE "Calcs: WTARes: $WTAResult[$i] WTAExpRes: $WTAExpRes[$i]\r\n";
		print DEBUGFILE "       SoSRes: $SoSResult[$i]/$SoSDenominator SoSExpRes: $SoSExpRes[$i]\r\n";
                print DEBUGFILE "       PPSCRes: $PPSCResult[$i] ActRes: $ActualResult[$i]\r\n";
                close(DEBUGFILE);
            }        
        }

        for (my $m = 0; $m < $VPlayers ; $m++)
        {
            $SecondPlacePoints[$m] = 0;
            for (my $n = 0; $n < $VPlayers ; $n++)
            {
                if ($n != $m)
                {
                    $SecondPlacePoints[$m] = $SecondPlacePoints[$m] + (($WTAExpRes[$n] * $WTAExpRes[$m]) / (1 - $WTAExpRes[$n]));
                }
            }
            $SecondPlacePoints[$m] = $SecondPlacePoints[$m] * (1 - $WTAExpRes[$m]);
        }

        $SecondPlacePointsSum = 0;
        for (my $m = 0; $m < $VPlayers ; $m++)
        {
            $SecondPlacePointsSum = $SecondPlacePointsSum + $SecondPlacePoints[$m];
        }
   
        for (my $m = 0; $m < $VPlayers ; $m++)
        {
            if ($debug >= 1)
            {
                open(DEBUGFILE, ">>debug.txt") or die("Unable to open debug.txt file");
                print DEBUGFILE "Subtraction:  = (($VictorySC * $WTAExpRes[$m]) + ((($VSCCount - $VictorySC) * $SecondPlacePoints[$m]) / $SecondPlacePointsSum)) / $VSCCount \r\n";
                close(DEBUGFILE);
            }        

            $PPSCExpRes[$m] = (($VictorySC * $WTAExpRes[$m]) + ((($VSCCount - $VictorySC) * $SecondPlacePoints[$m]) / $SecondPlacePointsSum)) / $VSCCount;

            if ($ppsc == 1)
            {
                $ExpRes[$m] = $PPSCExpRes[$m]
            }
        }

        if ($debug >= 1)
        {
            for (my $m = 0; $m < $VPlayers ; $m++)
            {
                open(DEBUGFILE, ">>debug.txt") or die("Unable to open debug.txt file");
                print DEBUGFILE "PlayerNumber: $Games->{$gameNum}{ $m }{PlayerID}\r\n";
                print DEBUGFILE "Calcs: WTARes: $WTAResult[$m] WTAExpRes: $WTAExpRes[$m]\r\n";
                print DEBUGFILE "       PPSCRes: $PPSCResult[$m] ActRes: $PPSCExpRes[$m]\r\n";
                print DEBUGFILE "       ActRes: $ActualResult[$m] ExpRes: $ExpRes[$m]\r\n";
                print DEBUGFILE "       2ndPP: $SecondPlacePoints[$m]\r\n";
                close(DEBUGFILE);
            }
        }

        
        for (my $m = 0; $m < $VPlayers ; $m++)
        {
            if ($outputGameTest == 1)
            {
                open(TESTFILE, ">>testfile.txt") or die("Unable to open debug.txt file");
                my $WTA = 1;
                if ($Games->{$gameNum}{ GameType } =~ m/Winner-takes-all/i)
                {
                    $WTA = 2;
                }
                my $GameEnd = 0;
                if ($Games->{$gameNum}{ $m }{ Outcome } =~ m/Drawn/)
                {
                    $GameEnd = 1;
                }
                elsif ($Games->{$gameNum}{ $m }{ Outcome } =~ m/Won/)
                {
                    $GameEnd = 2;
                }
                print TESTFILE "$gameNum\t$Games->{$gameNum}{ $m }{ PlayerID }\t$Games->{$gameNum}{ $m }{ SCCount }\t$GameEnd\t$WTA\t$Players->{ $Games->{$gameNum}{ $m }{PlayerID} }{GhostRating}\r\n";
                close(TESTFILE);                
            }
            if ($debug >= 1)
            {
                open(DEBUGFILE, ">>debug.txt") or die("Unable to open debug.txt file");
                print DEBUGFILE "GR Update: $Games->{$gameNum}{ $m }{ PlayerID } old: $Players->{ $Games->{$gameNum}{ $m }{ PlayerID } }{GhostRating}\r\n";
                close(DEBUGFILE);
            }
            
            if ($debug >= 1)
            {
                if ($Games->{$gameNum}{ $m }{ PlayerID } >= 1 and $Games->{$gameNum}{ $m }{ PlayerID } <= 9)
                {
                    open(DEBUGFILE, ">>debug.txt") or die("Unable to open debug.txt file");
                    print DEBUGFILE "Fake Player\r\n";
                    close(DEBUGFILE);
                    next;
                }
            }

            $Players->{ $Games->{$gameNum}{ $m }{ PlayerID } }{GhostRating} = $GhostRatings[$m] + (($GhostSum/$ModValue) * ($ActualResult[$m] - $ExpRes[$m]));
            if ($Players->{ $Games->{$gameNum}{ $m }{ PlayerID }}{PeakRating} < $Players->{ $Games->{$gameNum}{ $m }{ PlayerID } }{GhostRating})
            {
                $Players->{ $Games->{$gameNum}{ $m }{ PlayerID }}{PeakRating} = $Players->{ $Games->{$gameNum}{ $m }{ PlayerID } }{GhostRating};
            }
            if ($Players->{ $Games->{$gameNum}{ $m }{ PlayerID }}{MonthPeakRating} < $Players->{ $Games->{$gameNum}{ $m }{ PlayerID } }{GhostRating})
            {
                $Players->{ $Games->{$gameNum}{ $m }{ PlayerID }}{MonthPeakRating} = $Players->{ $Games->{$gameNum}{ $m }{ PlayerID } }{GhostRating};
            }
            
            $Players->{ $Games->{$gameNum}{ $m }{ PlayerID }}{Games} = $Players->{ $Games->{$gameNum}{ $m }{ PlayerID }}{Games} + 1;

            if ($debug >= 1)
            {
                open(DEBUGFILE, ">>debug.txt") or die("Unable to open debug.txt file");
                print DEBUGFILE "new: $Players->{ $Games->{$gameNum}{ $m }{ PlayerID }}{GhostRating} \r\n";
                if ($debug >= 2)
                {
                    if (($Players->{ $Games->{$gameNum}{ $m }{ PlayerID } }{GhostRating} > 400) or ($Players->{ $Games->{$gameNum}{ $m }{ PlayerID } }{GhostRating} < 20))
                    {
                        print DEBUGFILE "CHECK: $Players->{ $Games->{$gameNum}{ $m }{ PlayerID } }{GhostRating}\n";
                    }
                }
                close(DEBUGFILE);
            }
        }
    }
    else
    {
        if ($debug >= 1)
        {
            open(DEBUGFILE, ">>debug.txt") or die("Unable to open debug.txt file");
            print DEBUGFILE "Fail ".$gameNum." - ".$Games->{$gameNum}{ Players }."\r\n";
            close(DEBUGFILE);
        }

        open(NOPROCESS, ">>NotProcessed.txt") or die("Unable to open NotProcessed.txt file");
        if ($VPlayers == 0)
        {
            print NOPROCESS "$gameNum - 7\r\n";
        }
        else
        {
		    if ($Games->{$gameNum}{ Players } != $VPlayers)
			{
			    print NOPROCESS "$gameNum - 13\r\n";
			}
			if ($Games->{$gameNum}{ GameTurns } <= 3)
			{
                print NOPROCESS "$gameNum - 14\r\n";
			}
			if (!($Games->{$gameNum}{ GameOutcome } =~ m/Won/ or $Games->{$gameNum}{ GameOutcome } =~ m/Drawn/))
			{
                print NOPROCESS "$gameNum - 15\r\n";
			}
        }
        close(NOPROCESS);
		
        
        return;
    }
}

sub GenerateProcessTime
{
    my ($GPTGameId,$GPTLastGame) = @_;

    my $GPTFoundEarlier = 0;
    my $GPTFoundLater = 0;
    my $GPTWorkingId = $GPTGameId - 1;

    if ($debug >= 1)
    {
        open(DEBUGFILE, ">>debug.txt") or die("Unable to open debug.txt file");
        print DEBUGFILE "Generate Process Time $GPTGameId $GPTLastGame\r\n";
        close(DEBUGFILE);
    }
    
    while ($GPTFoundEarlier == 0)
    {
       if ($debug >= 3)
       {
           open(DEBUGFILE, ">>debug.txt") or die("Unable to open debug.txt file");
           print DEBUGFILE "Loop1: $GPTFoundEarlier $GPTWorkingId\r\n";
           close(DEBUGFILE);
       }

       if ($GPTWorkingId < 0)
       {
           $GPTFoundEarlier = -1;
       }
       elsif (!defined($Games->{ $GPTWorkingId }))
       {
       }
       elsif ($Games->{ $GPTWorkingId }{ TurnLength } == $Games->{ $GPTGameId }{ TurnLength })
       {
           if ($Games->{ $GPTWorkingId }{ ProcessTime } != -1)
           {
               $GPTFoundEarlier = $Games->{ $GPTWorkingId }{ ProcessTime };
           }
       }
       $GPTWorkingId = $GPTWorkingId - 1;
       
    }

    $GPTWorkingId = $GPTGameId;

    while ($GPTFoundLater == 0)
    {
        if ($debug >= 3)
        {
            open(DEBUGFILE, ">>debug.txt") or die("Unable to open debug.txt file");
            print DEBUGFILE "Loop1: $GPTFoundLater $GPTWorkingId\r\n";
            close(DEBUGFILE);
        }
       if ($GPTWorkingId > $GPTLastGame)
       {
           $GPTFoundLater = -1;
       }
       elsif (!defined($Games->{ $GPTWorkingId }))
       {
       }
       elsif ($Games->{ $GPTWorkingId }{ TurnLength } == $Games->{ $GPTGameId }{ TurnLength })
       {
           if ($Games->{ $GPTWorkingId }{ ProcessTime } != -1)
           {
               $GPTFoundLater = $Games->{ $GPTWorkingId }{ ProcessTime };
           }
       }
       $GPTWorkingId = $GPTWorkingId + 1;
    }
        if ($debug >= 3)
        {
            open(DEBUGFILE, ">>debug.txt") or die("Unable to open debug.txt file");
            print DEBUGFILE "Loop1: $GPTFoundEarlier $GPTFoundLater\r\n";
            close(DEBUGFILE);
        }

    if ($GPTFoundLater == -1 && $GPTFoundEarlier == -1)
    {
        return 1;
    }
    elsif ($GPTFoundLater == -1)
    {
        return $GPTFoundEarlier + 1;
    }
    elsif ($GPTFoundEarlier == -1)
    {
        return $GPTFoundLater - 1;
    }
    else
    {
        return ($GPTFoundLater + $GPTFoundEarlier) / 2;
    }
}

sub OutputMonthGhostRatings
{    
    my ($Month) = @_;
    my $outputFile = ">months/GhostRatings-".$Month.".csv";
    my $peakOutputFile = ">months/PeakRatings-".$Month.".csv";
    

    mkdir 'months' unless -d 'months';

    open(MONTHOUTFILE, $outputFile) or die("Couldn't open output file");
    binmode MONTHOUTFILE;
    
    open(PEAKMONTHOUTFILE, $peakOutputFile) or die("Couldn't open output file");
    binmode PEAKMONTHOUTFILE;
    
    @keys = sort {
        $Players->{$b}{GhostRating} <=> $Players->{$a}{GhostRating}
            or
        $a <=> $b    
    } keys %$Players;
    
    $numPlayers = @keys;
    print MONTHOUTFILE "Rank, Player, PlayerID, Ghost Rating, Games Played, Peak Ghost Rating, ChangeRank, ChangeGames, ChangeGhostRating, Last Game Date\n";
    print PEAKMONTHOUTFILE "Rank, Player, PlayerID, Peak Ghost Rating\n";
    $rank = 1;
    for ($i=0 ; $i<$numPlayers ; $i++)
    {
        if (($Players->{$keys[$i]}{Games} > 0) && (($monthsBeforeDrop == 0) || ($Players->{$keys[$i]}{AwayMonths} < $monthsBeforeDrop)))
        {
            if ($Players->{$keys[$i]}{LastGames} == 0)
            {
                $ChangeRank = "New Entry";
                $ChangeGames = "New Entry";
                $ChangeGhostRating = "New Entry";
                $Players->{$keys[$i]}{Dropped} = 0;
            }
            elsif ($Players->{$keys[$i]}{Dropped} == 1)
            {
                $ChangeRank = "Re-Entry";
                $ChangeGames = "Re-Entry";
                $ChangeGhostRating = "Re-Entry";
                $Players->{$keys[$i]}{Dropped} = 0;
            }
            else
            {
                $ChangeRank = $Players->{$keys[$i]}{LastRank} - $rank;
                $ChangeGames =  $Players->{$keys[$i]}{Games} - $Players->{$keys[$i]}{LastGames};
                $ChangeGhostRating = $Players->{$keys[$i]}{GhostRating} - $Players->{$keys[$i]}{LastGhostRating};
                $Players->{$keys[$i]}{Dropped} = 0;
            }
            ($esec, $emin, $ehr, $oeday, $oemon, $oeyear) = localtime($Players->{$keys[$i]}{LastGame});
            $oeyear = $oeyear + 1900;
            $oemon++;
            if ($oemon < 10)
            {
                $oemon = "0" . $oemon;
            }
            if ($oeday < 10)
            {
                $oeday = "0" . $oeday;
            }
            $LastDate = "$oeyear-$oemon-$oeday";

            print MONTHOUTFILE "$rank, \"$Players->{$keys[$i]}{PlayerName}\", $keys[$i], $Players->{$keys[$i]}{GhostRating}, $Players->{$keys[$i]}{Games}, $Players->{$keys[$i]}{PeakRating}, $ChangeRank, $ChangeGames, $ChangeGhostRating, $LastDate\n";
            $Players->{$keys[$i]}{LastRank} = $rank;
            $Players->{$keys[$i]}{LastGames} = $Players->{$keys[$i]}{Games};
            $Players->{$keys[$i]}{LastGhostRating} = $Players->{$keys[$i]}{GhostRating};
            $rank++;
        }
        if ($Players->{$keys[$i]}{AwayMonths} >= $monthsBeforeDrop)
        {
            $Players->{$keys[$i]}{Dropped} = 1;
        }
    }
    @keys = sort {
        $Players->{$b}{PeakRating} <=> $Players->{$a}{PeakRating}
            or
        $a <=> $b    
    } keys %$Players;
    
    $rank = 1;
    for ($i=0 ; $i<$numPlayers ; $i++)
    {
        
        #if (($Players->{$keys[$i]}{Games} == 0) && (($monthsBeforeDrop == 0) || ($Players->{$keys[$i]}{AwayMonths} < $monthsBeforeDrop)))
        #{
        #print MONTHOUTFILE "--, \"$Players->{$keys[$i]}{PlayerName}\", $keys[$i], $Players->{$keys[$i]}{GhostRating}, $Players->{$keys[$i]}{Games}, $Players->{$keys[$i]}{PeakRating}\n";
        #}
        if ($Players->{$keys[$i]}{Games} > 0)
        {
            print PEAKMONTHOUTFILE "$rank, \"$Players->{$keys[$i]}{PlayerName}\", $keys[$i], $Players->{$keys[$i]}{PeakRating}\n";
        }

        $Players->{$keys[$i]}{AwayMonths} = $Players->{$keys[$i]}{AwayMonths} + 1;
        $Players->{$keys[$i]}{MonthPeakRating} = $Players->{$keys[$i]}{GhostRating};
        $rank++;
    }
    close(MONTHOUTFILE);
    close(PEAKMONTHOUTFILE);
}

sub CheckForExclude
{    
    ($gameNum) = @_;
    $mExclude = 0;
    $FoundOne = 0;
    $FoundTwo = 0;

    for ($p = 0 ; $p < $Exclude->{NumExcludes} ; $p++)
    {
        $FoundOne = $mExclude;
        $FoundTwo = $mExclude;
        $ExcludeLine = $Exclude->{$p};
        @ExcludeArray = split(/,/, $ExcludeLine);
        foreach $PlayerNum (@ExcludeArray)
        {
            for (my $k = 0; $k < $VPlayers ; $k++)
            {
                if ($debug >= 6)
                {
                    open(DEBUGFILE, ">>debug.txt") or die("Unable to open debug.txt file");
                    print DEBUGFILE "ExcludeCheck: $Games->{$gameNum}{ $k }{ PlayerID } $PlayerNum\r\n";
                    close(DEBUGFILE);
                }
                
                if ($Games->{$gameNum}{ $k }{ PlayerID } == $PlayerNum)
                {
                    if ($FoundOne != 1)
                    {
                        $FoundOne = 1;
                    }
                    else
                    {
                        $FoundTwo = 1;
                    }
                }
            }
        }
        $mExclude = $FoundOne && $FoundTwo;
    }

    return $mExclude;
}

#main
$path = shift;
#$outputGameTest = shift;
#$debug = shift;
$variantFile = shift;
$excludeFile = shift;
$optionArg = shift;
$monthsBeforeDrop = shift;
$startID = shift;
$lastID = shift;
$fBeginDate = shift;
$fEndDate = shift;

$kNoChat = 0;
$kPublicPress = 0;
$kNormalChat = 0;
if ($optionArg-256 >= 0)
{
    $kNoChat = 1;
    $optionArg -= 256;
}
if ($optionArg-128 >= 0)
{
    $kPublicPress = 1;
    $optionArg -= 128;
}
if ($optionArg-64 >= 0)
{
    $kNormalChat = 1;
    $optionArg -= 64;
}

$kLive = 0;
$kNonLive = 0;
if ($optionArg-32 >= 0)
{
    $kLive = 1;
    $optionArg -= 32;
}
if ($optionArg-16 >= 0)
{
    $kNonLive = 1;
    $optionArg -= 16;
}

if ($optionArg-8 >= 0)
{
    $optionArg -= 8;
}

$kPPSC = 0;
$kWTA = 0;
$outputGameTest = 0;
$debug = 0;
if ($optionArg-4 >= 0)
{
    $kPPSC = 1;
    $optionArg -= 4;
}
if ($optionArg-2 >= 0)
{
    $kWTA = 1;
    $optionArg -= 2;
}
if ($optionArg > 0)
{
    $outputGameTest = 1;
    $debug = 1;
}

if ($startID <= 0)
{
    $startID = 0;
}
if ($monthsBeforeDrop <= 0)
{
    $monthsBeforeDrop = 0;
}

open(FILE,$variantFile) or die("Unable to open datafile $variantFile");
@data = <FILE>;
close(FILE);

my $numLines = @data;
foreach $line1 (@data)
{
    chomp($line1);
    @lineData1 = split(/,/, $line1);
    $Variants->{$lineData1[0]}{Name} = $lineData1[1];
    $Variants->{$lineData1[0]}{SCCount} = $lineData1[2];
    $Variants->{$lineData1[0]}{VictorySCCount} = $lineData1[3];
    $Variants->{$lineData1[0]}{PlayerCount} = $lineData1[4];
    $Variants->{$lineData1[0]}{VMod} = $lineData1[5];
    $Variants->{$lineData1[0]}{Active} = $lineData1[6];
}

open(FILE, $excludeFile) or die("Unable to open exclude file $excludeFile");
@data = <FILE>;
close(FILE);

$NumPlayers = 0;
foreach $line1 (@data)
{
    chomp($line1);
    #@lineData1 = split(/,/, $line1);
    $Exclude->{$NumPlayers} = $line1;
    $NumPlayers++;
    $Exclude->{NumExcludes} = $NumPlayers;
}

open(FILE, $path) or die("Unable to open datafile $path");
@data = <FILE>;
close(FILE);

$numLines = @data;
my $inGames = 0;
for ($i = 0 ; $i < $numLines ; $i++)
{
    if ($data[$i] =~ /gameID/ && $data[$i] =~ /phaseMinutes/)
    {
        $inGames = 1;
        $inPlayers = 0;
    }
    elsif ($data[$i] =~ /username/ && $data[$i] =~ /id/)
    {
        $inPlayers = 1;
        $inGames = 0;
    }
    elsif ($inPlayers)
    {
        push(@playerData, $data[$i]);
    }
    elsif ($inGames)
    {
        push(@gameData, $data[$i]);
    }
}
if ($debug >= 1)
{
    open(DEBUGFILE, ">debug.txt") or die("Unable to open debug.txt file");
    print DEBUGFILE "1 Processing Players\r\n";
    close(DEBUGFILE);
}
open(NOPROCESS, ">NotProcessed.txt") or die("Unable to open NotProcessed.txt file");
print NOPROCESS "Games Excluded From Calculation\r\n";
print NOPROCESS "Key: \r\n";
print NOPROCESS "   1) Exclude File Check\r\n";
print NOPROCESS "   2) PPSC Excluded\r\n";
print NOPROCESS "   3) WTA Excluded\r\n";
print NOPROCESS "   4) NO Chat Excluded\r\n";
print NOPROCESS "   5) Normal Chat Excluded\r\n";
print NOPROCESS "   6) Public Press Excluded\r\n";
print NOPROCESS "   7) Variant Error\r\n";
print NOPROCESS "   8) Variant Disabled\r\n";
print NOPROCESS "   9) Before Start ID\r\n";
print NOPROCESS "   10) After Last ID\r\n";
print NOPROCESS "   11) Before Start Date\r\n";
print NOPROCESS "   12) After Start Date\r\n";
print NOPROCESS "   13) Player Count Wrong\r\n"; 
print NOPROCESS "   14) Before Turn 4\r\n"; 
print NOPROCESS "   15) Not Finished\r\n"; 
print NOPROCESS "   16) Live Games Excluded\r\n"; 
print NOPROCESS "   17) Non-Live Games Excluded\r\n";
print NOPROCESS "   18) Unranked Game\r\n";
close(NOPROCESS);

my $firstLine = 1;
print "Processing players\n";
foreach $line1 (@playerData)
{
    #if ($firstLine)
    #{
    #$firstLine = 0;
    #next;
    #}
    chomp($line1);
    #$line1 =~ s/^"//g;
    #$line1 =~ s/^"(\d+)", "/\1<COMMA>/g;
    $line1 =~ s/^"(\d+)",[^"]*"/$1,/g;
    $line1 =~ s/^(\d+),/$1<COMMA>/g;
    $line1 =~ s/<COMMA> /<COMMA>/g;
    $line1 =~ s/,,+//g;
    $line1 =~ s/\cM//g;
    $line1 =~ s/"$//g;
    $line1 =~ s/"/\"/g;

    if ($debug >= 3)
    {
        open(DEBUGFILE, ">>debug.txt") or die("Unable to open debug.txt file");
        print DEBUGFILE "Player Line: $line1\r\n";
        close(DEBUGFILE);
    }
    
    @lineData1 = split(/<COMMA>/, $line1);
    if (!defined($lineData1[1]))
    {
        $lineData1[1] = "   ";
    }
    $lineData1[1] =~ s/,/-/g;

    $Players->{ $lineData1[0] } = {
                                    PlayerName => $lineData1[1],
                                    GhostRating => 100,
                                    PeakRating => 100,
                                    Games => 0,
                                    LastGames => 0,
                                    LastGhostRating => 100,
                                    LastRank => 0,
                                    MonthPeakRating => 100,
                                    AwayMonths => $monthsBeforeDrop,
                                    LastGame => 0,
                                    Dropped => 0,
                                };

    $PlayerArray[$lineData1[0]][0] = $lineData1[0];
    $PlayerArray[$lineData1[0]][1] = $lineData1[1];
    $PlayerArray[$lineData1[0]][10] = 1;
    if (($PlayerArray[$lineData1[0]][0] >= 1) and ($PlayerArray[$lineData1[0]][0] <= 9))
    {
        $Players->{ $lineData1[0] }{ GhostRating } = 0;
        $PlayerArray[$lineData1[0]][2] = 0;
    }
    else
    {
        $PlayerArray[$lineData1[0]][2] = 100;
    }
}
#print Dumper(\$Players);

$firstLine = 1;
print "Pre-processing games\r\n";
if ($debug >= 1)
{
    open(DEBUGFILE, ">>debug.txt") or die("Unable to open debug.txt file");
    print DEBUGFILE "Pre-processing games\r\n";
    close(DEBUGFILE);
}

my $HighestGameId = 0;

foreach $line (@gameData)
{
    if ($line =~ m/^\s*$/ or $line =~ m/gameID/)
    {
        next;
    }
    chomp($line);
    $line =~ s/"//g;
    $line =~ s/ //g;
    $line =~ s/\cM//g;
    @lineData = split(/,/, $line);

    if (defined($Games->{ $lineData[1] }))
    {
        $PlayerNum = $Games->{ $lineData[1] }->{ Players };
    }
    else
    {
        $PlayerNum = 0;
    }
    $Games->{ $lineData[1] }{ variantID } = $lineData[0];
    $Games->{ $lineData[1] }{ ProcessTime } = $lineData[10];
    $Games->{ $lineData[1] }{ TurnLength } = $lineData[8];
    $Games->{ $lineData[1] }{ Players } = $PlayerNum+1;
    $Games->{ $lineData[1] }{ GameType } = $lineData[7];
    $Games->{ $lineData[1] }{ GameOutcome } = $lineData[4];
    $Games->{ $lineData[1] }{ PressType } = $lineData[11];
    $Games->{ $lineData[1] }{ GameTurns } = $lineData[9];
    $Games->{ $lineData[1] }{ $PlayerNum } = {
                                Outcome => $lineData[5],
                                SCCount => $lineData[6],
                                PlayerID => $lineData[2],
                            };

    if (!($Games->{ $lineData[1] }{ ProcessTime } =~ m/\d/))
    {
        if ($debug >= 3)
        {
            open(DEBUGFILE, ">>debug.txt") or die("Unable to open debug.txt file");
            print DEBUGFILE "ProcessTime-Set $lineData[1]\r\n";
            close(DEBUGFILE);
        }
        
        $Games->{ $lineData[1] }{ ProcessTime } = -1;
    }
    if ( $lineData[1] > $HighestGameId )
    {
        $HighestGameId = $lineData[1];
    }
}

if ($lastID <= 0)
{
    $lastID = $HighestGameId;
}

#print Dumper(\$Games);

$numGamesToProcess = 0;

$numGamesToProcess = keys %$Games;
$NumGamesPerPercent = $numGamesToProcess / 20;
$PercentDone = 0;

#print "\n Begin Dumper\n";
#print Dumper(\$Games);
#print "\n End Dumper\n";

my @keys = sort {
    $a <=> $b
} keys %$Games;

open(DEBUGFILE5, ">GeneratedProcessTimes.txt") or die("Unable to open debug.txt file");
for ($j=0 ; $j<$numGamesToProcess ; $j++)
{
    #print "\nProcessTime - $Games->{$keys[$j]}{ProcessTime}\n";
    if ($Games->{$keys[$j]}{ProcessTime} == -1)
    {
        $Games->{$keys[$j]}{ProcessTime} = GenerateProcessTime($keys[$j], $HighestGameId);

        print DEBUGFILE5 "$keys[$j] - $Games->{$keys[$j]}{ProcessTime}\r\n";
    }
}
close(DEBUGFILE5);

@keys = sort {
    $Games->{$a}{ProcessTime} <=> $Games->{$b}{ProcessTime}
        or
    $a <=> $b
} keys %$Games;

#@TempKeys = keys %$Games;
#@Gameskeys = sort{ $a <=> $b } keys %$Games;

#print DEBUGFILE6 Dumper(@keys);
if ($debug >= 2)
{
    open(DEBUGFILE5, ">ProcessOrder.txt") or die("Unable to open debug.txt file");

    $numKeys = @keys;
    for ($i=0 ; $i<$numKeys ; $i++)
    {
        print DEBUGFILE5 "$keys[$i]\r\n";
    }
    close(DEBUGFILE5);    
}

print "\r\nProcessing games\r\n";
if ($debug >= 1)
{
    open(DEBUGFILE, ">>debug.txt") or die("Unable to open debug.txt file");
    print DEBUGFILE "Processing games\r\n";
    close(DEBUGFILE);
}

#foreach $i (@processOrder)
$PercentDone = 0;
($esec, $emin, $ehr, $eday, $emon, $eyear) = localtime($Games->{$keys[0]}{ProcessTime});
$eyear += 1900;
$emon++;
if ($emon < 10)
{
    $emon = "0" . $emon;
}

$GamesThisMonth = 0;

$lastMonth = $eyear ."-". $emon;
for ($j=0 ; $j<$numGamesToProcess ; $j++)
{
    ($esec, $emin, $ehr, $eday, $emon, $eyear) = localtime($Games->{$keys[$j]}{ProcessTime});
    $eyear += 1900;
    $emon++;
    if ($emon < 10)
    {
        $emon = "0" . $emon;
    }    
    $currentMonth = $eyear . "-". $emon;

    if ($lastMonth ne $currentMonth)
    {
        if ($GamesThisMonth)
        {
            &OutputMonthGhostRatings($currentMonth);
            $GamesThisMonth = 0;
        }
        $lastMonth = $currentMonth;
    }
    if ($j % $NumGamesPerPercent == 0)
    {
        print "Finished: $PercentDone%\r\n";
        $PercentDone = $PercentDone + 5;
    }
    if ($debug >= 2)
    {
        open(DEBUGFILE, ">>debug.txt") or die("Unable to open debug.txt file");
        print DEBUGFILE "Process: $j $keys[$j]\r\n"; 
        close(DEBUGFILE);
    }
    &CalculateGameOutcome($keys[$j]);
}
#&OutputMonthGhostRatings($currentMonth);

$numPlayers = 0;
print "\r\nRanking players\r\n";
if ($debug >= 1)
{
    open(DEBUGFILE, ">>debug.txt") or die("Unable to open debug.txt file");
    print DEBUGFILE "Ranking players\r\n";
    close(DEBUGFILE);
}

print "Creating GhostRating file\r\n";
if ($debug >= 1)
{
    open(DEBUGFILE, ">>debug.txt") or die("Unable to open debug.txt file");
    print DEBUGFILE "Creating GhostRating file\r\n";
    close(DEBUGFILE);
}

open(OUTFILE, ">GhostRatings.csv");
binmode OUTFILE;
@keys = sort {
    $Players->{$b}{GhostRating} <=> $Players->{$a}{GhostRating}
        or
    $a <=> $b    
} keys %$Players;

$numPlayers = @keys;
print OUTFILE "Rank, Player, PlayerID, Ghost Rating, Games Played, Peak Ghost Rating\n";
$rank = 1;
for ($i=0 ; $i<$numPlayers ; $i++)
{
    if ($Players->{$keys[$i]}{Games} > 0)
    {
        print OUTFILE "$rank, \"$Players->{$keys[$i]}{PlayerName}\", $keys[$i], $Players->{$keys[$i]}{GhostRating}, $Players->{$keys[$i]}{Games}, $Players->{$keys[$i]}{PeakRating}\n";
        $rank++;
    }
}
for ($i=0 ; $i<$numPlayers ; $i++)
{
    if ($Players->{$keys[$i]}{Games} == 0)
    {
        print OUTFILE "--, \"$Players->{$keys[$i]}{PlayerName}\", $keys[$i], $Players->{$keys[$i]}{GhostRating}, $Players->{$keys[$i]}{Games}, $Players->{$keys[$i]}{PeakRating}\n";
    }
}

close(OUTFILE);
