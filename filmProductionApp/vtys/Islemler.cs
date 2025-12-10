using Npgsql;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace vtys
{
    public partial class Islemler : Form
    {
        public Islemler()
        {
            InitializeComponent();
        }
        NpgsqlConnection baglanti = new NpgsqlConnection("server=localHost;port=5432;Database=FilmProduction;user ID=postgres;password=Katalahali");
        private void btnPuan_Click(object sender, EventArgs e)
        {
            if (!decimal.TryParse(txtPuan.Text, out decimal minScore))
            {
                MessageBox.Show("Lutfen minimum puan icin gecerli bir rakam girin.");
                return;
            }


            string sorgu = "SELECT * FROM get_films_by_min_score_simple(@MinScore)";

            try
            {

                NpgsqlDataAdapter da = new NpgsqlDataAdapter(sorgu, baglanti);


                da.SelectCommand.Parameters.AddWithValue("@MinScore", minScore);

                DataSet ds = new DataSet();
                da.Fill(ds, "Filmler");

                // 3. Nəticəni DataGridView-ə yükləyin
                if (ds.Tables.Count > 0)
                {
                    dataGridView1.DataSource = ds.Tables[0];
                }
                else
                {
                    dataGridView1.DataSource = null;
                    MessageBox.Show("Hicbir film bulunamadi.");
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Veri cekme sirasinda bir hata olustu:\n{ex.Message}");
            }
        }

        private void btnSeeReleases_Click(object sender, EventArgs e)
        {
            if (!int.TryParse(txtId.Text, out int id))
            {
                MessageBox.Show("Lütfen film ID'si icin gecerli bir tam sayi girin.");
                return;
            }

            string sorgu = "SELECT * FROM get_film_releases_by_film(@id)";

            try
            {

                NpgsqlDataAdapter da = new NpgsqlDataAdapter(sorgu, baglanti);


                da.SelectCommand.Parameters.AddWithValue("@id", id);

                DataSet ds = new DataSet();
                da.Fill(ds, "Filmler");

                // 3. Nəticəni DataGridView-ə yükləyin
                if (ds.Tables.Count > 0)
                {
                    dataGridView1.DataSource = ds.Tables[0];
                }
                else
                {
                    dataGridView1.DataSource = null;
                    MessageBox.Show("Hicbir film bulunamadi.");
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Veri cekme sirasinda bir hata olustu:\n{ex.Message}");
            }
        }
        private void DisplayJsonInDataGridView(string json)
        {
            try
            {
                // Tək JSON Obyektini DataGridView üçün Key/Value Cədvəlinə çevirmə
                var jObject = JObject.Parse(json);
                DataTable dt = new DataTable();
                dt.Columns.Add("Key");
                dt.Columns.Add("Value");

                foreach (var property in jObject.Properties())
                {
                    // Massivləri (məsələn, aktyorlar, rejissorlar) string kimi göstəririk
                    dt.Rows.Add(property.Name, property.Value.ToString());
                }

                dataGridView1.DataSource = dt;
            }
            catch (Exception ex)
            {
                MessageBox.Show($"JSON-u DataGridView üçün formatlama zamanı xəta: {ex.Message}\nJSON: {json}");
                // Xəta halında orijinal JSON-u görə bilmək üçün mesajı genişləndirə bilərsiniz.
            }
        }

        private void btnFullFilm_Click(object sender, EventArgs e)
        {
            if (!int.TryParse(txtId.Text, out int filmId))
            {
                MessageBox.Show("Lütfen film ID'si icin gecerli bir tam sayi girin.");
                return;
            }

            string sorgu = "SELECT get_complete_film_info(@FilmID)";

            try
            {
                using (var cmd = new NpgsqlCommand(sorgu, baglanti))
                {
                    if (baglanti.State != ConnectionState.Open)
                        baglanti.Open();

                    cmd.Parameters.AddWithValue("@FilmID", filmId);

                    object result = cmd.ExecuteScalar();

                    if (result != null)
                    {
                        string jsonResult = result.ToString();
                        DisplayJsonInDataGridView(jsonResult);
                    }
                    else
                    {
                        dataGridView1.DataSource = null;
                        MessageBox.Show($"ID {filmId} olan film icin tam bilgi bulunamadi.");
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Veri cekme sirasinda bir hata olustu:\n{ex.Message}");
            }
            finally
            {
                if (baglanti.State == ConnectionState.Open)
                    baglanti.Close();
            }
        }



        private void Islemler_Load(object sender, EventArgs e)
        {

        }

        // Certifique-se de que esta é a assinatura correta do seu evento
        private void btnPersonId_Click(object sender, EventArgs e)
        {
            // NpgsqlCommand komut1 needs to be accessible in 'finally' block for disposal
            NpgsqlCommand cmd = null;

            // --- 1. VALIDATION ---
            // Check if the input is a valid integer ID
            if (!int.TryParse(txtPersonId.Text, out int personId))
            {
                MessageBox.Show("Lütfen gecerli bir kisi ID'si girin.", "Input Error", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }
            // ----------------------

            try
            {
                // Open the connection (assumindo que 'baglanti' está acessível e configurada)
                if (baglanti.State != ConnectionState.Open)
                    baglanti.Open();

                // 2. DEFINE O PROCEDIMENTO
                cmd = new NpgsqlCommand("get_person_full_info", baglanti);
                // Informa ao Npgsql que estamos chamando um PROCEDURE (CALL)
                cmd.CommandType = CommandType.StoredProcedure;

                // 3. PARAMETRO IN (ENTRADA)
                cmd.Parameters.AddWithValue("p_personid", personId);

                // 4. PARAMETRO OUT (SAÍDA - O JSON)
                NpgsqlParameter outParam = new NpgsqlParameter("result", NpgsqlTypes.NpgsqlDbType.Json);
                outParam.Direction = ParameterDirection.Output;
                cmd.Parameters.Add(outParam);

                // 5. EXECUTA O PROCEDURE (ExecuteNonQuery é usado para CALL)
                cmd.ExecuteNonQuery();

                // 6. OBTÉM O RESULTADO JSON
                if (outParam.Value != null && outParam.Value != DBNull.Value)
                {
                    string jsonResult = outParam.Value.ToString();

                    // Verifica se a base_info (person) foi encontrada (o JSON deve ser maior que um JSON vazio)
                    if (jsonResult.Length > 10)
                    {
                        // *** CHAMA SUA FUNÇÃO EXISTENTE PARA EXIBIR O JSON NO DATAGRIDVIEW ***
                        DisplayJsonInDataGridView(jsonResult);
                    }
                    else
                    {
                        dataGridView1.DataSource = null;
                        MessageBox.Show($"ID {personId} icin detayli bilgi bulunamadi.", "Resultado Vazio", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    }
                }
                else
                {
                    dataGridView1.DataSource = null;
                    MessageBox.Show($"ID {personId} icin detayli bilgi bulunamadi.", "Resultado Vazio", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                }
            }
            catch (NpgsqlException ex)
            {
                // Catch database errors (e.g., connection fail or procedure error)
                MessageBox.Show("Veritabani Hatasi: " + ex.Message, "Erro", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
            catch (Exception ex)
            {
                // Catch general application errors
                MessageBox.Show("Bir hata oluştu: " + ex.Message, "Erro", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
            finally
            {
                // Ensure connection is closed
                if (baglanti != null && baglanti.State == ConnectionState.Open)
                {
                    baglanti.Close();
                }
                // Dispose of the command object
                if (cmd != null)
                {
                    cmd.Dispose();
                }
            }
        }
    }
}

    



    

