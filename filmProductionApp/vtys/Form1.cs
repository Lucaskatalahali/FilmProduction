using Npgsql;
using System.Data;
using System.Reflection;
using System;
using System.Windows.Forms; // Ensure this is included for MessageBox

namespace vtys
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
        }
        NpgsqlConnection baglanti = new NpgsqlConnection("server=localHost;port=5432;Database=FilmProduction;user ID=postgres;password=Katalahali");

        private void btnEkle_Click(object sender, EventArgs e)
        {
            // NpgsqlCommand komut1 needs to be accessible in 'finally' block for disposal
            NpgsqlCommand komut1 = null;

            // --- NEW: C# VALIDATION TO PREVENT CRASHES AND ENSURE DATA ---
            if (string.IsNullOrWhiteSpace(txtFilmAdi.Text) || cmbKategori.SelectedItem == null)
            {
                MessageBox.Show("Filmin basligi ve kategori zorunludur.", "Input Error", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }
            // -----------------------------------------------------------

            // Existing code block for reading and converting data:
            string secilenKategori = cmbKategori.SelectedItem.ToString();

            // --- NEW: LOGIC TO HANDLE NULLABLE IMDB AND DURATION ---

            // Check if Duration is provided and convert to TimeSpan
            object durationValue = null;
            if (!string.IsNullOrWhiteSpace(txtDuration.Text))
            {
                // Try to parse the duration input
                if (int.TryParse(txtDuration.Text, out int dakikaCinsindenSure))
                {
                    // 2. Tamsayı dakikayı TimeSpan nesnesine çevir
                    durationValue = TimeSpan.FromMinutes(dakikaCinsindenSure);
                }
                else
                {
                    MessageBox.Show("Sure, bir tam sayi olmalidir.", "Input Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                    return;
                }
            }
            // If txtDuration is empty, durationValue remains null (DB null)

            // Check if IMDB is provided and convert to Double
            object imdbValue = null;
            if (!string.IsNullOrWhiteSpace(txtImdb.Text))
            {
                // Try to parse the IMDB input
                if (double.TryParse(txtImdb.Text, out double imdbScore))
                {
                    imdbValue = imdbScore;
                }
                else
                {
                    MessageBox.Show("IMDB gecerli bir sayi olmalidir.", "Input Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                    return;
                }
            }
            // If txtImdb is empty, imdbValue remains null (DB null)
            // ----------------------------------------------------

            bool isAnimation = (secilenKategori == "Animation");
            bool isLiveAction = (secilenKategori == "Live Action");

            try
            {
                // Open the connection inside the try block
                baglanti.Open();

                // Command instantiation 
                komut1 = new NpgsqlCommand("insert into \"Film\"(title,imdb,animation,\"liveAction\",duration)values (@p1,@p2,@p3,@p4,@p5)", baglanti);

                // Parameter assignment (Original code)
                komut1.Parameters.AddWithValue("@p1", txtFilmAdi.Text);
                // Use imdbValue which can be double or DBNull.Value (null)
                komut1.Parameters.AddWithValue("@p2", imdbValue ?? DBNull.Value); // NEW: Use DBNull.Value for PostgreSQL NULL
                komut1.Parameters.AddWithValue("@p3", isAnimation);
                komut1.Parameters.AddWithValue("@p4", isLiveAction);
                // Use durationValue which can be TimeSpan or DBNull.Value (null)
                komut1.Parameters.AddWithValue("@p5", durationValue ?? DBNull.Value); // NEW: Use DBNull.Value for PostgreSQL NULL


                // Execute the insert command
                komut1.ExecuteNonQuery();

                // If successful:
                btnListele_Click(sender, e);
                MessageBox.Show("Film ekleme islemi basarili!", "Bilgi", MessageBoxButtons.OK, MessageBoxIcon.Information);
            }
            // Catch PostgreSQL specific exceptions (database errors like triggers failing)
            catch (NpgsqlException ex)
            {
                // Display the database error message (e.g., the RAISE EXCEPTION message from the trigger)
                MessageBox.Show("Database Validation Failed: " + ex.Message, "Database Error", MessageBoxButtons.OK, MessageBoxIcon.Warning);
            }
            // Catch all other exceptions (e.g., connection issues, general errors)
            catch (Exception ex)
            {
                // Display generic error message
                MessageBox.Show("An unexpected error occurred: " + ex.Message, "Fatal Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
            // Ensures cleanup happens whether the code succeeds or fails
            finally
            {
                // Close the connection if it is open (prevents resource leaks)
                if (baglanti != null && baglanti.State == ConnectionState.Open)
                {
                    baglanti.Close();
                }
                // Dispose of the command object
                if (komut1 != null)
                {
                    komut1.Dispose();
                }
            }
        }

        private void btnListele_Click(object sender, EventArgs e)
        {
            string sorgu = "select * from \"Film\"";
            NpgsqlDataAdapter da = new NpgsqlDataAdapter(sorgu, baglanti);
            DataSet ds = new DataSet();
            da.Fill(ds);
            dataGridView1.DataSource = ds.Tables[0];
        }

        private void btnSil_Click(object sender, EventArgs e)
        {
            // --- NEW: C# VALIDATION TO PREVENT CRASHES ---
            if (string.IsNullOrWhiteSpace(txtId.Text) || !int.TryParse(txtId.Text, out _))
            {
                MessageBox.Show("Lutfen silmek icin gecerli bir film ID'si girin", "Input Error", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }
            // ---------------------------------------------

            try
            {
                baglanti.Open();
                NpgsqlCommand komut2 = new NpgsqlCommand("Delete from \"Film\" where \"filmId\"=@p1", baglanti);
                komut2.Parameters.AddWithValue("@p1", int.Parse(txtId.Text));
                komut2.ExecuteNonQuery();
                btnListele_Click(sender, e);
                // baglanti.Close(); // Moved to finally
                MessageBox.Show("Film silme islemi basarili!", "Bilgi", MessageBoxButtons.OK, MessageBoxIcon.Stop);
            }
            catch (Exception ex)
            {
                MessageBox.Show("Filmi silme basarisiz oldu: " + ex.Message, "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
            finally
            {
                // Ensure the connection is closed
                if (baglanti != null && baglanti.State == ConnectionState.Open)
                {
                    baglanti.Close();
                }
            }
        }


        private void btnGuncelle_Click(object sender, EventArgs e)
        {
            // --- NEW: C# VALIDATION FOR UPDATE (ONLY FILM ID IS REQUIRED) ---
            if (string.IsNullOrWhiteSpace(txtId.Text) || !int.TryParse(txtId.Text, out _))
            {
                MessageBox.Show("Lutfen guncellemek icin gecerli bir film ID'si girin", "Input Error", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }
            // Removed: Strict validation for title and category. Only ID is mandatory here.

            // --- NEW: LOGIC TO HANDLE NULLABLE IMDB AND DURATION FOR UPDATE ---

            // Check if Duration is provided and convert to TimeSpan
            object durationValue = null;
            if (!string.IsNullOrWhiteSpace(txtDuration.Text))
            {
                // Try to parse the duration input
                if (int.TryParse(txtDuration.Text, out int dakikaCinsindenSure))
                {
                    // 2. Tamsayı dakikayı TimeSpan nesnesine çevir
                    durationValue = TimeSpan.FromMinutes(dakikaCinsindenSure);
                }
                else
                {
                    MessageBox.Show("Sure, bir tam sayi olmalidir.", "Input Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                    return;
                }
            }

            // Check if IMDB is provided and convert to Double
            object imdbValue = null;
            if (!string.IsNullOrWhiteSpace(txtImdb.Text))
            {
                // Try to parse the IMDB input
                if (double.TryParse(txtImdb.Text, out double imdbScore))
                {
                    imdbValue = imdbScore;
                }
                else
                {
                    MessageBox.Show("IMDB gecerli bir sayi olmalidir.", "Input Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                    return;
                }
            }
            // ----------------------------------------------------

            NpgsqlCommand komut3 = null;

            try
            {
                // Check if a category was selected (mandatory if we want to change animation/liveAction flags)
                bool isAnimation = false;
                bool isLiveAction = false;

                // --- NEW: Safely get category flags if item is selected ---
                if (cmbKategori.SelectedItem != null)
                {
                    string secilenKategori = cmbKategori.SelectedItem.ToString();
                    isAnimation = (secilenKategori == "Animation");
                    isLiveAction = (secilenKategori == "Live Action");
                }
                // ---------------------------------------------------------

                baglanti.Open();
                komut3 = new NpgsqlCommand("update \"Film\" set title=@p1,imdb=@p2,animation=@p3,\"liveAction\"=@p4,duration=@p5 where \"filmId\"=@p6", baglanti);

                // int dakikaCinsindenSure = Convert.ToInt32(txtDuration.Text); // Removed: replaced by TryParse above

                // 2. Tamsayı dakikayı TimeSpan nesnesine çevir
                // TimeSpan durationInterval = TimeSpan.FromMinutes(dakikaCinsindenSure); // Removed
                // ----------------------------------------------------

                // The title parameter must be explicitly checked for null/empty for UPDATE
                object titleValue = string.IsNullOrWhiteSpace(txtFilmAdi.Text) ? null : txtFilmAdi.Text;

                komut3.Parameters.AddWithValue("@p1", titleValue ?? DBNull.Value); // NEW: Use titleValue which can be NULL if empty
                komut3.Parameters.AddWithValue("@p2", imdbValue ?? DBNull.Value); // NEW: Use DBNull.Value for PostgreSQL NULL
                komut3.Parameters.AddWithValue("@p3", isAnimation);
                komut3.Parameters.AddWithValue("@p4", isLiveAction);
                komut3.Parameters.AddWithValue("@p5", durationValue ?? DBNull.Value); // NEW: Use DBNull.Value for PostgreSQL NULL
                komut3.Parameters.AddWithValue("@p6", int.Parse(txtId.Text));

                komut3.ExecuteNonQuery();
                // baglanti.Close(); // Moved to finally
                MessageBox.Show("Guncelleme islemi basarili!", "Bilgi", MessageBoxButtons.OK, MessageBoxIcon.Stop);
            }
            catch (NpgsqlException ex)
            {
                // Catch database errors (like triggers)
                MessageBox.Show("Database Validation Failed: " + ex.Message, "Database Error", MessageBoxButtons.OK, MessageBoxIcon.Warning);
            }
            catch (Exception ex)
            {
                MessageBox.Show("Filmi guncelleme basarisiz oldu.: " + ex.Message, "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
            finally
            {
                // Ensure the connection is closed
                if (baglanti != null && baglanti.State == ConnectionState.Open)
                {
                    baglanti.Close();
                }
                // Dispose of the command object
                if (komut3 != null)
                {
                    komut3.Dispose();
                }
            }
        }
        private void btnAra_Click(object sender, EventArgs e)
        {

            if (string.IsNullOrWhiteSpace(txtAra.Text))
            {
                MessageBox.Show("Lütfen aramak istediğiniz filmin başlığını girin.", "Uyarı", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                // Boşsa tüm listeyi göstermek için Listele metodunu çağırabilirsiniz:
                // btnListele_Click(sender, e);
                return;
            }
            try
            {
                //
                string sorgu = "SELECT * FROM \"Film\" WHERE title ILIKE @p1";

                NpgsqlDataAdapter da = new NpgsqlDataAdapter(sorgu, baglanti);


                da.SelectCommand.Parameters.AddWithValue("@p1", "%" + txtAra.Text + "%");

                DataSet ds = new DataSet();
                da.Fill(ds);


                dataGridView1.DataSource = ds.Tables[0];

                // Bağlantıyı burada açıp kapatmaya gerek yok, DataAdapter bunu kendisi halleder.
            }
            catch (Exception ex)
            {
                MessageBox.Show("Arama sırasında hata oluştu: " + ex.Message, "Hata", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private void btnIslem_Click(object sender, EventArgs e)
        {
            Islemler newIslemlerFormu = new Islemler();

            // 2. Bu yeni nesneyi ekranda gösterin
            newIslemlerFormu.Show();
        }

        private void btnKisiListele_Click(object sender, EventArgs e)
        {
            string sorgu2 = "select * from \"person\".\"Person\"";
            NpgsqlDataAdapter da = new NpgsqlDataAdapter(sorgu2, baglanti);
            DataSet ds = new DataSet();
            da.Fill(ds);
            dataGridView1.DataSource = ds.Tables[0];

        }

        private void label2_Click(object sender, EventArgs e)
        {

        }

        private void dataGridView1_CellContentClick(object sender, DataGridViewCellEventArgs e)
        {

        }
    }
}