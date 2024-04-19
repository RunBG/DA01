--EX01
WITH twt_years_spend AS
(
  SELECT 
  EXTRACT(YEAR FROM transaction_date) AS year, 
  product_id,
  spend AS curr_year_spend,
  LAG(spend) OVER(PARTITION BY product_id ORDER BY EXTRACT(YEAR FROM transaction_date) ) AS prev_year_spend
  FROM user_transactions 
)

SELECT 
year,
product_id,
curr_year_spend,
prev_year_spend,
ROUND(100.0*(curr_year_spend-prev_year_spend)/prev_year_spend,2) AS yoy_rate
FROM twt_years_spend 
--EX02
WITH rank_card AS
(
  SELECT card_name, issued_amount, RANK() OVER(PARTITION BY card_name ORDER BY issue_year, issue_month) AS card_rank
  
  FROM monthly_cards_issued 
)
SELECT  card_name, issued_amount
FROM rank_card
WHERE card_rank =1
ORDER BY issued_amount DESC
--EX03
WITH find_transaction AS
(
  SELECT 
  user_id,
  spend, 
  transaction_date, 
  ROW_NUMBER() OVER(PARTITION BY user_id ORDER BY transaction_date) AS rank_spend
  FROM transactions 
)
SELECT  
 user_id,
  spend, 
  transaction_date
FROM find_transaction
WHERE rank_spend =3
--EX04
WITH latest_transactions AS
(
SELECT 
   transaction_date, 
   user_id, 
   product_id, 
RANK() OVER (
   PARTITION BY user_id 
   ORDER BY transaction_date DESC) AS days_rank 
FROM user_transactions
)
SELECT  transaction_date, user_id,
COUNT(product_id) as purchase_count
FROM latest_transactions
WHERE days_rank =1
GROUP BY  transaction_date,user_id
ORDER BY transaction_date
--EX05
SELECT 
  user_id,
  tweet_date,
  CASE
  WHEN Ranks=1 THEN ROUND(count_roll/1.0,2)
  WHEN Ranks=2 THEN ROUND(count_roll/2.0,2)
  ELSE ROUND(count_roll/3.0,2)
  END  AS rolling_average 
  FROM
  (
      SELECT
        user_id,
        tweet_date ,
        Ranks,
        (tweet_count+COALESCE(Lag1,0)+COALESCE(Lag2,0)) AS count_roll
        FROM(
          SELECT  
              user_id,
              tweet_date ,
              tweet_count,
              ROW_NUMBER()OVER(
                PARTITION BY user_id
                ORDER BY tweet_date) AS Ranks,
              Lag(tweet_count) OVER(
                PARTITION BY user_id
                ORDER BY tweet_date ) AS Lag1,
              Lag(tweet_count,2) OVER(
                PARTITION BY user_id
                ORDER BY tweet_date ) AS Lag2
          FROM tweets)
          AS Roll_tweet
  ) AS rolling_avg_3d;
--EX06
with payment AS
(SELECT 
transaction_id, merchant_id, credit_card_id, amount, 
transaction_timestamp-lag(transaction_timestamp) over( PARTITION BY merchant_id, credit_card_id, amount order by transaction_timestamp ) as diff_time
FROM transactions)

select count(*) as payment_count
from payment
where diff_time <= '00:10:00'
--EX07 đã làm ở EX02 Buổi 13
--EX08
WITH rank_artist AS 
(
  SELECT a.artist_name, SUM(rank),
  DENSE_RANK() OVER (ORDER BY COUNT(s.song_id) DESC) AS artist_rank
  FROM artists a
  JOIN songs s USING (artist_id)
  JOIN global_song_rank g USING (song_id)
  WHERE g.rank <=10
  GROUP BY a.artist_name
)
SELECT artist_name, artist_rank
FROM rank_artist
WHERE artist_rank <= 5

