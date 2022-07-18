#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# Delete everything from all tables at the start of each run
echo $($PSQL "TRUNCATE games, teams")

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT W_GOALS O_GOALS
do
  # Make sure not to get the top row ... only has labels
  if [[ $YEAR != "year" ]]
  then
    # Look for the team
    W_TEAM=$($PSQL "SELECT name FROM teams WHERE name='$WINNER'")
    O_TEAM=$($PSQL "SELECT name FROM teams WHERE name='$OPPONENT'")
    # Add the winning teams that are NOT in the DB already 
    if [[ -z $W_TEAM ]]
    then 
      # Insert the winning team into teams
      INSERT_WINNER_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER');")
      # Check to see if the team was added correctly
      if [[ $INSERT_WINNER_RESULT == "INSERT 0 1" ]]
      then 
        echo Team $WINNER inserted correctly
      fi
    fi
    # Add the opponent teams that are NOT in the DB already 
    if [[ -z $O_TEAM ]]
    then 
      # Insert the oppenent team into teams
      INSERT_OPP_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT');")
      # Check to see if the team was added correctly
      if [[ $INSERT_OPP_RESULT == "INSERT 0 1" ]]
      then 
        echo Team $OPPONENT inserted correctly 
      fi
    fi 
  fi
done

  # ---------- END OF ADDINE TO TEAMS TABLE AND START OF ADDING TO GAMES TABLE ---------- 

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT W_GOALS O_GOALS
do
if [[ $YEAR != "year" ]]
  then
    # Get each team id
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER';")
    OPP_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT';")
    # Add to the table
    INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(round, year, winner_id, winner_goals, opponent_goals, opponent_id) VALUES('$ROUND', $YEAR, $WINNER_ID, $W_GOALS, $O_GOALS, $OPP_ID);")
    if [[ $INSERT_GAME_RESULT == "INSERT 0 1" ]] 
    then
      echo "Year $YEAR Game $ROUND of $WINNER_ID ($W_GOALS) vs. $OPP_ID ($O_GOALS) was added!"
    fi
  fi
done
